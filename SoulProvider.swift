import SwiftUI
import AVFAudio

@main
struct SoulProvider: App {
    @StateObject private var fetcher = RadioMetadataFetcher()
    @StateObject private var player = RadioPlayer()
    
    init() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, policy: .longFormAudio)
        } catch {
            print("Failed to set audio session route sharing policy: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RadioView()
                .environmentObject(fetcher)
                .environmentObject(player)
        }
    }
}
