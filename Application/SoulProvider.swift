import MediaPlayer
import SwiftUI

@main
struct SoulProvider: App {
  private var audioSession: AVAudioSession? = nil
  
  @StateObject private var metadataFetcher = RadioMetadataFetcherModel()
  @StateObject private var player = RadioPlayerModel()
  @StateObject private var settings = SettingsModel()
  
  var body: some Scene {
    WindowGroup {
      RadioView()
        .environmentObject(metadataFetcher)
        .environmentObject(player)
        .environmentObject(settings)
        .task {
          try? await metadataFetcher.fetch()
        }
    }
  }
}
