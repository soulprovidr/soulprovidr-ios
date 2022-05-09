enum SettingsColorScheme: String, CaseIterable, Identifiable, Codable {
  case system, light, dark
  var id: Self { self }
}
