import Foundation
import SwiftUI

struct RadioView: View {
    @EnvironmentObject private var metadataFetcher: RadioMetadataFetcher
    @EnvironmentObject private var player: RadioPlayer
    @Environment(\.colorScheme) var colorScheme
    
    var buttonIcon: String {
        return player.status == RadioStatus.stopped ? "play.fill" : "pause.fill"
    }

    func handleListenPress() -> Void {
        if player.status == RadioStatus.stopped {
            player.listen()
        } else {
            player.pause()
        }
    }

    var body: some View {
        VStack {
            if let metadata = metadataFetcher.metadata {
                RadioHeaderView()
                Spacer()
                RadioMetadataView(metadata: metadata, status: player.status)
                RadioProgressView(duration: metadata.duration, startedAt: metadata.started_at, status: player.status)
                Spacer()
                Button {
                    handleListenPress()
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
                LoadingView(err: metadataFetcher.err, onTryAgainPress: {
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
