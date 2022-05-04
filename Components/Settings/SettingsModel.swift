import SwiftUI

@MainActor
class SettingsModel: ObservableObject {
    @Environment(\.colorScheme) var colorScheme

    @Published var userColorScheme: ColorScheme?
}
