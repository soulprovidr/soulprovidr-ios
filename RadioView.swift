import Foundation
import SwiftUI

struct LiveIcon: View {
    let size: CGFloat

    @State var isVisible = true

    let timer = Timer.publish(every: 0.75, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Circle()
            .fill(Color(UIColor(.red)))
            .frame(width: size, height: size, alignment: .center)
            .opacity(isVisible ? 1 : 0)
            .onReceive(timer) { _ in
                withAnimation {
                    isVisible = !isVisible
                }
            }
    }
}

var HeaderView: some View {
    HStack {
        HStack {
            LogoView(size: 32)
            Text("SOUL PROVIDER")
                .font(.system(size: 16, weight: .bold))
                .offset(x: 4)
        }
        Spacer()
        HStack {
            LiveIcon(size: 6)
                .offset(x: 2)
            Text("LIVE")
                .font(.system(size: 14, weight: .semibold))
        }.frame(alignment: .center)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
}

struct RadioMetadataView: View {
    var metadata: RadioMetadata
    var status: RadioStatus

    @State var isCoverLoaded = false

    var body: some View {
        VStack {
            AsyncImage(url: metadata.cover) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(4)
                    .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.10), radius: 5)
                    .opacity(isCoverLoaded ? 1 : 0)
                    .frame(idealWidth: 400)
                    .onAppear {
                        withAnimation {
                            isCoverLoaded = true
                        }
                    }
            } placeholder: {
                Rectangle()
                    .fill(.clear)
                    .aspectRatio(1.0, contentMode: .fit)
            }
            HStack {
                VStack {
                    Text(metadata.title)
                        .font(.system(size: 24, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 10)
                        .lineLimit(1)
                    Text(metadata.artist)
                        .font(.system(size: 20))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(1)
                }
                Spacer()
                (status == RadioStatus.buffering ? ProgressView() : nil)
            }
        }
    }
}

struct RadioProgressView: View {
    var duration: Double
    var startedAt: String
    var status: RadioStatus

    @State private var elapsed = 0.0

    let progressTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    var progressBarColour: Color {
        return status == RadioStatus.playing ? Color(UIColor(.blue)) : Color("ProgressBarFgColor")
    }

    var progressBarValue: Double {
        return min(1, Double(elapsed) / Double(duration))
    }

    func handleProgressTimer() {
        elapsed = min(abs(ISO8601DateFormatter().date(from: startedAt)!.addingTimeInterval(10).timeIntervalSinceNow), TimeInterval(duration))
    }

    func secondsToTime(s: Double) -> String {
        let minutes = Int(s) / 60 % 60
        let seconds = Int(s) % 60
        return String(format:"%02i:%02i", minutes, seconds)
    }

    var body: some View {
        Group {
            Rectangle()
                .fill(.clear)
                .frame(height: 4)
                .background {
                    GeometryReader { geometry in
                        let width = progressBarValue * geometry.size.width
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color("ProgressBarBgColor"))
                                .frame(height: 1)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(progressBarColour)
                                .frame(width: width, height: 4)
                                .onReceive(progressTimer) { _ in handleProgressTimer() }
                        }.frame(height: 4)
                    }
                }
            HStack {
                Text("\(secondsToTime(s: elapsed))")
                    .font(.caption)
                Spacer()
                Text("\(secondsToTime(s: duration))")
                    .font(.caption)
            }
        }.padding([.top], 10)
    }
}

struct RadioView: View {
    @EnvironmentObject private var metadataFetcher: RadioMetadataFetcher
    @EnvironmentObject private var player: RadioPlayer
    @Environment(\.colorScheme) var colorScheme
    
    var buttonIcon: String {
        return player.status == RadioStatus.stopped ? "play.fill" : "pause.fill"
    }

    func handleListenClick() -> Void {
        if player.status == RadioStatus.stopped {
            player.listen()
        } else {
            player.pause()
        }
    }

    var body: some View {
        VStack {
            if let metadata = metadataFetcher.metadata {
                HeaderView
                Spacer()
                RadioMetadataView(metadata: metadata, status: player.status)
                RadioProgressView(duration: metadata.duration, startedAt: metadata.started_at, status: player.status)
                Spacer()
                Button {
                    handleListenClick()
                } label: {
                    Image(systemName: buttonIcon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35, height: 35)
                        .padding()
                }
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .alert("Couldn't load the stream", isPresented: $player.err) {
                        Button("Try again") {
                            // Do nothing (for now)
                        }
                    } message: {
                        Text("Stay tuned while we resolve the issue.")
                    }
                Spacer()
            } else {
                LoadingView(err: metadataFetcher.err, onTryAgainClick: {
                    Task {
                        try? await metadataFetcher.fetch()
                    }
                })
            }
        }
        .padding()
        .background(Color("BgColor"))
        .foregroundColor(Color("FgColor"))
    }
}
