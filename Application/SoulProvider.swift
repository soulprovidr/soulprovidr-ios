import Combine
import MediaPlayer
import SwiftUI

@main
struct SoulProvider: App {
  @StateObject private var metadataModel = RadioMetadataModel()
  @StateObject private var playerModel = RadioPlayerModel()
  
  var body: some Scene {
    WindowGroup {
      RadioView()
        .environmentObject(metadataModel)
        .environmentObject(playerModel)
        .task {
          try? await metadataModel.sync()
        }
    }
  }
}
