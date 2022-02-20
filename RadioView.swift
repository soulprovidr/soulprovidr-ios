import Foundation
import SwiftUI

enum RadioStatus {
    case stopped
    case buffering
    case playing
}

var HeaderView: some View {
    HStack {
        Image("SPLogoRounded")
            .resizable()
            .scaledToFit()
            .frame(width: 32, height: 32)
        Text("SOUL PROVIDER")
            .font(.system(size: 16, weight: .bold))
            .offset(x: 5)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
}

struct RadioMetadataView: View {
    var radioMetadata: RadioMetadata
    var body: some View {
        VStack {
            AsyncImage(url: radioMetadata.cover) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFit()
                } else {
                    ProgressView()
                }
            }
            .cornerRadius(4)
            .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.10), radius: 5)
            Text(radioMetadata.title)
                .font(.system(size: 24, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 10)
            Text(radioMetadata.artist)
                .font(.system(size: 20))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct RadioProgressView: View {
    var duration: Double
    var startedAt: String

    let progressTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    @State private var elapsed = 0.0

    func getProgress() -> Double { min(1, Double(elapsed) / Double(duration)) }

    func handleProgressTimer() {
        elapsed = abs(ISO8601DateFormatter().date(from: startedAt)!.addingTimeInterval(10).timeIntervalSinceNow)
    }

    func secondsToTime(s: Double) -> String {
        let minutes = Int(s) / 60 % 60
        let seconds = Int(s) % 60
        return String(format:"%02i:%02i", minutes, seconds)
    }

    var body: some View {
        
        VStack {
            ProgressView(value: getProgress())
                .onReceive(progressTimer) { _ in handleProgressTimer() }
            HStack {
                Text("\(secondsToTime(s: elapsed))")
                    .font(.caption)
                Spacer()
                Text("\(secondsToTime(s: duration))")
                    .font(.caption)
            }
        }.padding(.top, 10)
    }
}

struct RadioView: View {
    @EnvironmentObject private var fetcher: RadioMetadataFetcher
    @EnvironmentObject private var player: RadioPlayer

    func handleListenClick() -> Void {
        if player.status == RadioPlayerStatus.stopped {
            player.listen()
        } else {
            player.stop()
        }
    }

    var body: some View {
        VStack {
            if let radioMetadata = fetcher.radioMetadata {
                HeaderView
                Spacer()
                RadioMetadataView(radioMetadata: radioMetadata)
                RadioProgressView(duration: radioMetadata.duration, startedAt: radioMetadata.started_at)
                Spacer()
                ZStack {
                    Button {
                        handleListenClick()
                    } label: {
                        Image(systemName: player.status == RadioPlayerStatus.stopped ? "play.fill" : "pause.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 35, height: 35)
                            .padding()
                    }.foregroundColor(.black)
                }
            } else {
                ProgressView()
            }
        }
        .padding()
        .task {
            try? await fetcher.fetch()
        }
    }
}
