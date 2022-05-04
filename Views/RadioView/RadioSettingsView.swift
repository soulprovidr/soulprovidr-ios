import SwiftUI

struct RadioSettingsView: View {
    var hide: () -> Void
    
    @EnvironmentObject private var settingsModel: SettingsModel
    @Environment(\.colorScheme) var systemColorScheme

    @State var selectedColorScheme = 0

    var versionNumber: String {
        if let text = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return text
        }
        return ""
    }

    var body: some View {
        NavigationView {
            VStack {
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
                Form {
                    Section() {
                        Picker(selection: $selectedColorScheme, label: Text("Appearance")) {
                            Text("Dark").tag(0)
                            Text("Light").tag(1)
                        }
                        .onAppear() {
                            let colorScheme = settingsModel.userColorScheme ?? systemColorScheme
                            switch colorScheme {
                            case .dark:
                                selectedColorScheme = 0
                            case .light:
                                selectedColorScheme = 1
                            default:
                                break
                            }
                        }
                        .onChange(of: selectedColorScheme) { value in
                            switch value {
                            case 0:
                                settingsModel.userColorScheme = .dark
                            case 1:
                                settingsModel.userColorScheme = .light
                            default:
                                break
                            }
                        }
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
                        hide()
                    }
            )
        }
    }
}
