import SwiftUI
import AVFAudio

@main
struct SoulProvider: App {
    @StateObject private var fetcher = RadioMetadataFetcher()
    @StateObject private var player = RadioPlayer()

    var body: some Scene {
        WindowGroup {
            RadioView()
                .environmentObject(fetcher)
                .environmentObject(player)
                .preferredColorScheme(.light)
        }
    }
}
