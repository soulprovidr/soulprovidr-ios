import AVFoundation
import Foundation
import GoogleCast
import SwiftUI

struct RadioView: View {
  @EnvironmentObject private var metadataModel: RadioMetadataModel
  @EnvironmentObject private var playerModel: RadioPlayerModel
  
  @State private var isPopoverVisible = false
  
  func handleListenTap() {
    if playerModel.status == .stopped {
      playerModel.listen()
    } else {
      playerModel.pause()
    }
  }

  var buttonIcon: String {
    return playerModel.status == .stopped ? "play.fill" : "pause.fill"
  }
  
  var listenButton: some View {
    Image(systemName: buttonIcon)
      .resizable()
      .scaledToFit()
      .foregroundColor(Color("FgColor"))
      .frame(width: 35, height: 35)
      .padding()
      .onTapGesture(perform: handleListenTap)
      .alert("Couldn't load the stream", isPresented: $playerModel.err) {
        Button("Try again") {
          // Do nothing (for now)
        }
      } message: {
        Text("Stay tuned while we resolve the issue.")
      }
  }
  
  var body: some View {
    VStack {
      if let metadata = metadataModel.metadata {
        RadioHeaderView(onTapGesture: {
          isPopoverVisible = true
        })
        Spacer()
        RadioMetadataView(
          metadata: metadata,
          status: playerModel.status
        )
        RadioProgressView(
          duration: metadata.duration,
          startedAt: metadata.started_at,
          status: playerModel.status
        )
        Spacer()
        HStack {
          Spacer()
          DevicePickerView()
            .frame(width: 50, height: 50)
          Spacer()
          listenButton
          Spacer()
          ChromecastButtonView()
            .frame(width: 50, height: 50)
          Spacer()
        }
        Spacer()
      } else {
        LoadingView(err: metadataModel.err, onTryAgainPress: {
          Task {
            try? await metadataModel.sync()
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
    }
    .background(Color("BgColor"))
    .foregroundColor(Color("FgColor"))
  }
}
