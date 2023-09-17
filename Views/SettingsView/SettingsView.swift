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

  func renderLink(url: String, label: String, imageName: String? = nil) -> some View {
    Link(destination: URL(string: url)!) {
      HStack {
        if imageName != nil {
          Image(imageName!)
            .resizable()
            .cornerRadius(4)
            .scaledToFit()
            .frame(width: 20, height: 20)
        }
        Text(label)
      }
    }
  }
  
  var body: some View {
    NavigationView {
      VStack {
        appInformation
        Form {
          Section() {
            renderLink(url: "https://soulprovidr.fm", label: "Web Version", imageName: "SPLogo")
          }
          Section(header: Text("Social")) {
            renderLink(url: "https://github.com/soulprovidr", label: "GitHub", imageName: "GitHubLogo")
            renderLink(url: "https://soundcloud.com/soulprovidr", label: "SoundCloud", imageName: "SoundCloudLogo")
            renderLink(url: "https://youtube.com/@soulprovidr", label: "YouTube", imageName: "YouTubeLogo")
          }
          Section(header: Text("Legal")) {
            renderLink(url: "https://soulprovidr.fm/privacy", label: "Privacy Policy")
          }
        }
      }
      .background(Color("BgColor"))
      .foregroundColor(Color("FgColor"))
//      .navigationTitle("Settings")
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
