import SwiftUI
import AVFAudio
import MediaPlayer

@main
struct SoulProvider: App {
    private var audioSession: AVAudioSession? = nil

    @StateObject private var metadataFetcher = RadioMetadataFetcher()
    @StateObject private var player = RadioPlayer()

    var body: some Scene {
        WindowGroup {
            RadioView()
                .environmentObject(metadataFetcher)
                .environmentObject(player)
                .preferredColorScheme(.light)
                .task {
                    try? await metadataFetcher.fetch()
                }
        }
    }
}
