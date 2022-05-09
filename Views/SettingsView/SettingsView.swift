import SwiftUI
import AVFAudio

struct SettingsView: View {
  var hide: () -> Void

  @EnvironmentObject private var settings: SettingsModel
  
  var versionNumber: String {
    if let text = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
      return text
    }
    return ""
  }

  var appInformation: some View {
    HStack {
      Image("SPLogo")
        .resizable()
        .frame(width: 80, height: 80)
        .scaledToFit()
        .cornerRadius(16)
      VStack(alignment: .leading, spacing: 2) {
        Text("Soul Provider")
          .font(.callout)
          .fontWeight(.semibold)
        Text("Version \(versionNumber)")
          .font(.system(size: 14))
        
      }
      .padding(.leading, 10)
    }
    .padding([.top, .bottom], 20)
  }
  
  var colorSchemePicker: some View {
    Picker(selection: settings.$colorScheme, label: Text("Appearance")) {
      Text("System").tag(SettingsColorScheme.system)
      Text("Dark").tag(SettingsColorScheme.dark)
      Text("Light").tag(SettingsColorScheme.light)
    }
  }
  
  var body: some View {
    NavigationView {
      VStack {
        appInformation
        Form {
          Section() {
            colorSchemePicker
          }
        }
      }
      .background(Color("BgColor"))
      .foregroundColor(Color("FgColor"))
      .navigationTitle("Settings")
      .navigationBarTitleDisplayMode(.inline)
      .navigationBarItems(trailing:
        Text("Done")
          .padding(20)
          .foregroundColor(Color("AccentColor"))
          .onTapGesture {
            print(settings.colorScheme)
            hide()
          }
      )
    }
  }
}
