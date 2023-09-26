import AVFoundation
import Foundation
import GoogleCast
import SwiftUI
import MediaPlayer

let CHROMECAST_APP_ID = Bundle.main.infoDictionary?["CHROMECAST_APP_ID"] as! String
let STREAM_URL = URL(string: Bundle.main.infoDictionary?["STREAM_URL"] as! String)!

enum RadioStatus: String {
  case stopped
  case buffering
  case playing
}

class RadioPlayerModel: NSObject, ObservableObject, GCKSessionManagerListener, GCKRemoteMediaClientListener {
  
  private let audioSession = AVAudioSession.sharedInstance()
  private let remoteCommandCenter = MPRemoteCommandCenter.shared()
  private let player = AVPlayer()
  
  private var castMediaStatusObserver: NSKeyValueObservation?
  private var statusObserver: NSKeyValueObservation?
  private var timeControlStatusObserver: NSKeyValueObservation?
  
  private var castContext: GCKCastContext?
  private var castSessionManager: GCKSessionManager?
  private var isChromecastConnected = false
  
  @Published var err = false
  @Published var status = RadioStatus.stopped
  
  override init() {
    super.init()

    do {
      try audioSession.setCategory(.playback, mode: .default, policy: .longFormAudio)
    } catch {
      print("Failed to set audio session route sharing policy: \(error)")
    }
    
    // Initialize Chromecast.
    let criteria = GCKDiscoveryCriteria(applicationID: CHROMECAST_APP_ID)
    let options = GCKCastOptions(discoveryCriteria: criteria)
    GCKCastContext.setSharedInstanceWith(options)
    castContext = GCKCastContext.sharedInstance()
    castSessionManager = castContext?.sessionManager
    castSessionManager?.add(self)

    addInterruptionObserver()
    addLocalPlayerStatusObserver()
    addLocalPlayerTimeControlStatusObserver()
    addRemoteCommandTargets()
  }
  
  // Handle interruptions (incoming phone calls, Siri, etc.)
  private func addInterruptionObserver() {
    NotificationCenter.default.addObserver(
      forName: AVAudioSession.interruptionNotification,
      object: audioSession,
      queue: .main) { notification in
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
          return
        }
        switch type {
          case .began:
            self.pause()
          case .ended:
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
              self.listen()
            }
          default: ()
        }
      }
  }

  // Handle player errors.
  private func addLocalPlayerStatusObserver() {
    statusObserver = player.observe(\.status) { player, _ in
      DispatchQueue.main.async { [weak self] in
        guard let self = self else { return }
        let status = AVPlayer.Status(rawValue: player.status.rawValue)
        switch status {
          case .failed:
            err = true
          default:
            err = false
        }
      }
    }
  }
  
  // Observe and react to changes in player status.
  private func addLocalPlayerTimeControlStatusObserver() {
    timeControlStatusObserver = player.observe(\.timeControlStatus) { player, _ in
      DispatchQueue.main.async { [weak self] in
        guard let self = self else { return }
        let timeControlStatus = AVPlayer.TimeControlStatus(rawValue: player.timeControlStatus.rawValue)
        switch timeControlStatus {
          case .paused:
            status = .stopped
          case .waitingToPlayAtSpecifiedRate:
            status = .buffering
          case .playing:
            status = .playing
          default: ()
        }
      }
    }
  }
  
  // Handle incoming remote playback commands.
  private func addRemoteCommandTargets() {
    UIApplication.shared.beginReceivingRemoteControlEvents()
    remoteCommandCenter.playCommand.addTarget { _ in
      self.listen()
      return MPRemoteCommandHandlerStatus.success
    }
    remoteCommandCenter.pauseCommand.addTarget { _ in
      self.pause()
      return MPRemoteCommandHandlerStatus.success
    }
  }

  private func handleChromecastConnect() {
    isChromecastConnected = true
    castSessionManager?.currentCastSession?.remoteMediaClient?.add(self)
  }

  private func handleChromecastDisconnect() {
    isChromecastConnected = false
    castSessionManager?.currentCastSession?.remoteMediaClient?.remove(self)
  }

  private func handleChromecastListen() {
    let metadata = GCKMediaMetadata()
    metadata.setString("Soul Provider", forKey: kGCKMetadataKeyTitle)
    metadata.setString("Internet radio for those who like to groove.", forKey: kGCKMetadataKeySubtitle)
    metadata.addImage(GCKImage(url: URL(string: "https://soulprovidr.fm/logo.png")!, width: 256, height: 256))

    let mediaInfoBuilder = GCKMediaInformationBuilder.init(contentURL: STREAM_URL)
    mediaInfoBuilder.streamType = GCKMediaStreamType.live
    mediaInfoBuilder.contentType = "audio/mp3"
    mediaInfoBuilder.metadata = metadata
    
    let mediaInformation = mediaInfoBuilder.build()
    castSessionManager?.currentCastSession?.remoteMediaClient?.loadMedia(mediaInformation)
  }

  private func handleChromecastPause() {
    castSessionManager?.currentSession?.remoteMediaClient?.stop()
  }

  private func handleLocalListen() {
    let playerItem = AVPlayerItem(url: STREAM_URL)
    player.replaceCurrentItem(with: playerItem)
    do {
      try audioSession.setActive(true)
      player.play()
    } catch {
      print("Failed to activate audio session: \(error)")
    }
  }

  private func handleLocalPause() {
    player.pause()
  }

  func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
    switch mediaStatus?.playerState {
      case .buffering, .loading:
        status = RadioStatus.buffering
      case .playing:
        status = RadioStatus.playing
      default:
        status = RadioStatus.stopped
    }
  }

  func sessionManager(_ sessionManager: GCKSessionManager, didStart session: GCKSession) {
    handleChromecastConnect()
    if status != .stopped {
      handleLocalPause()
      handleChromecastListen()
    }
  }

  func sessionManager(_ sessionManager: GCKSessionManager, didResumeSession session: GCKSession) {
    handleChromecastConnect()
    handleLocalPause()
  }

  func sessionManager(_ sessionManager: GCKSessionManager, willEnd session: GCKSession) {
    handleChromecastDisconnect()
    if status != .stopped {
      handleLocalListen()
    }
  }

  func listen() {
    if isChromecastConnected {
      handleChromecastListen()
    } else {
      handleLocalListen()
    }
  }
  
  func pause() {
    if isChromecastConnected {
      handleChromecastPause()
    } else {
      handleLocalPause()
    }
  }
}
