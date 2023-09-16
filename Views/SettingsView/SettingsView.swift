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
      .padding(.bottom, 15)
      Text("\"Healing the world through the power of funk, soul, and software.\"")
        .italic()
        .font(.caption)
        .frame(width: 250, alignment: .center)
        .multilineTextAlignment(.center)
    }
    .padding([.top, .bottom], 20)
  }
  
  var body: some View {
    NavigationView {
      VStack {
        appInformation
        Form {
          Section(header: Text("Links")) {
            Link(destination: URL(string: "https://soulprovidr.fm")!) {
              HStack {
                Image("SPLogo")
                  .resizable()
                  .cornerRadius(4)
                  .scaledToFit()
                  .frame(width: 20, height: 20)
                Text("Official Website")
              }
            }
            Link(destination: URL(string: "https://github.com/soulprovidr")!) {
              HStack {
                Image("GitHubLogo")
                  .resizable()
                  .cornerRadius(4)
                  .scaledToFit()
                  .frame(width: 20, height: 20)
                Text("GitHub")
              }
            }
            Link(destination: URL(string: "https://soundcloud.com/soulprovidr")!) {
              HStack {
                Image("SoundCloudLogo")
                  .resizable()
                  .cornerRadius(4)
                  .scaledToFit()
                  .frame(width: 20, height: 20)
                Text("SoundCloud")
              }
            }
              Link(destination: URL(string: "https://youtube.com/@soulprovidr")!) {
                HStack {
                  Image("YouTubeLogo")
                    .resizable()
                    .cornerRadius(4)
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                  Text("YouTube")
                }
              }
          }
          Section(header: Text("Legal")) {
            Link("Privacy Policy", destination: URL(string: "https://soulprovidr.fm/privacy")!)
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
