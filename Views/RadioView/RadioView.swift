import Foundation
import SwiftUI

struct RadioView: View {
  @Environment(\.colorScheme) private var systemColorScheme: ColorScheme

  @EnvironmentObject private var metadataFetcher: RadioMetadataFetcherModel
  @EnvironmentObject private var player: RadioPlayerModel
  @EnvironmentObject private var settings: SettingsModel
  
  @State private var isPopoverVisible = false
  
  var buttonIcon: String {
    return player.status == RadioStatus.stopped ? "play.fill" : "pause.fill"
  }

  var preferredColorScheme: ColorScheme? {
    switch settings.colorScheme {
      case SettingsColorScheme.system:
        return nil
      case SettingsColorScheme.dark:
        return ColorScheme.dark
      case SettingsColorScheme.light:
        return ColorScheme.light
    }
  }
  
  var listenButton: some View {
    Image(systemName: buttonIcon)
      .resizable()
      .scaledToFit()
      .frame(width: 35, height: 35)
      .padding()
      .onTapGesture {
        if player.status == RadioStatus.stopped {
          player.listen()
        } else {
          player.pause()
        }
      }
      .foregroundColor(Color("FgColor"))
      .alert("Couldn't load the stream", isPresented: $player.err) {
        Button("Try again") {
          // Do nothing (for now)
        }
      } message: {
        Text("Stay tuned while we resolve the issue.")
      }
  }
  
  var body: some View {
    VStack {
      if let metadata = metadataFetcher.metadata {
        RadioHeaderView(onTapGesture: {
          isPopoverVisible = true
        })
        Spacer()
        RadioMetadataView(metadata: metadata, status: player.status)
        RadioProgressView(duration: metadata.duration, startedAt: metadata.started_at, status: player.status)
        Spacer()
        listenButton
        Spacer()
      } else {
        LoadingView(err: metadataFetcher.err, onTryAgainPress: {
          Task {
            try? await metadataFetcher.fetch()
          }
        })
      }
    }
    .frame(maxWidth: 430, maxHeight: 932)
    .padding()
    .sheet(isPresented: $isPopoverVisible) {
      SettingsView(hide: {
        isPopoverVisible = false
      })
      .colorScheme(preferredColorScheme ?? systemColorScheme)
    }
    .background(Color("BgColor"))
    .foregroundColor(Color("FgColor"))
    .preferredColorScheme(preferredColorScheme)
  }
}
