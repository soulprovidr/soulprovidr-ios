import SwiftUI

@MainActor
class SettingsModel: ObservableObject {
  @AppStorage("colorScheme") var colorScheme = SettingsColorScheme.system
}
