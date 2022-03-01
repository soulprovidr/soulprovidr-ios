import Foundation
import SwiftUI

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
    var metadata: RadioMetadata
    var body: some View {
        VStack {
            AsyncImage(url: metadata.cover) { phase in
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
            Text(metadata.title)
                .font(.system(size: 24, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 10)
            Text(metadata.artist)
                .font(.system(size: 20))
                .frame(maxWidth: .infinity, alignment: .leading)
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
        return status == RadioStatus.playing ? .blue : .gray
    }

    var progressBarValue: Double {
        return min(1, Double(elapsed) / Double(duration))
    }

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
            ProgressView(value: progressBarValue)
                .progressViewStyle(LinearProgressViewStyle(tint: progressBarColour))
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
    @EnvironmentObject private var player: RadioPlayer
    @Environment(\.colorScheme) var colorScheme
    
    var buttonIcon: String {
        return player.status == RadioStatus.stopped ? "play.fill" : "pause.fill"
    }

    func handleListenClick() -> Void {
        if player.status == RadioStatus.stopped {
            player.listen()
            vibrate()
        } else {
            player.stop()
        }
    }

    func vibrate() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    var body: some View {
        VStack {
            if let metadata = player.metadata, let status = player.status {
                HeaderView
                Spacer()
                RadioMetadataView(metadata: metadata)
                RadioProgressView(duration: metadata.duration, startedAt: metadata.started_at, status: status)
                Spacer()
                ZStack {
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
                }
            } else {
                ProgressView("Calibrating funk levels...")
            }
        }
        .padding()
        .task {
            try? await player.setupMetadataHandler()
        }
    }
}
