import SwiftUI
import AVFAudio
import MediaPlayer

@main
struct SoulProvider: App {
    private var audioSession: AVAudioSession? = nil

    @Environment(\.colorScheme) var systemColorScheme

    @StateObject private var metadataFetcher = RadioMetadataFetcher()
    @StateObject private var player = RadioPlayer()
    @StateObject private var settingsModel = SettingsModel()

    var body: some Scene {
        WindowGroup {
            RadioView()
                .environmentObject(metadataFetcher)
                .environmentObject(player)
                .environmentObject(settingsModel)
                .task {
                    try? await metadataFetcher.fetch()
                }
                .preferredColorScheme(settingsModel.userColorScheme ?? systemColorScheme)
        }
    }
}
