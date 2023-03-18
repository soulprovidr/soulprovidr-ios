import AVFoundation
import Foundation
import SwiftUI
import MediaPlayer

class RadioPlayerModel: ObservableObject {
  private let audioURL = URL(string: "https://www.radioking.com/play/soulprovidr")!
  
  private let audioSession = AVAudioSession.sharedInstance()
  private let remoteCommandCenter = MPRemoteCommandCenter.shared()
  
  private var interruptionObserver: NSObjectProtocol?
  private var statusObserver: NSKeyValueObservation?
  private var timeControlStatusObserver: NSKeyValueObservation?
  
  private let player = AVPlayer()
  
  @Published var elapsed: Double = 0.0
  @Published var err = false
  @Published var status = RadioStatus.stopped
  
  init() {
    do {
      try self.audioSession.setCategory(.playback, mode: .default)
    } catch {
      print("Failed to set audio session route sharing policy: \(error)")
    }
    
    // Handle interruptions (incoming phone calls, Siri, etc.)
    NotificationCenter.default.addObserver(
      forName: AVAudioSession.interruptionNotification,
      object: self.audioSession,
      queue: .main
    ) {
      [unowned self] notification in
      self.handleInterruption(notification: notification)
    }
    
    // Handle player errors.
    self.statusObserver = player.observe(\.status, options: [.new]) { (player, change) in
      DispatchQueue.main.async { [weak self] in
        guard let self = self else { return }
        let status = AVPlayer.Status(rawValue: player.status.rawValue)
        switch status {
          case .failed:
            self.err = true
          default:
            self.err = false
        }
      }
    }
    
    // Observe and react to changes in player status.
    self.timeControlStatusObserver = player.observe(\.timeControlStatus, options: [.new]) { (player, change) in
      DispatchQueue.main.async { [weak self] in
        guard let self = self else { return }
        let timeControlStatus = AVPlayer.TimeControlStatus(rawValue: player.timeControlStatus.rawValue)
        switch timeControlStatus {
          case .paused:
            self.status = RadioStatus.stopped
          case .waitingToPlayAtSpecifiedRate:
            self.status = RadioStatus.buffering
          case .playing:
            self.status = RadioStatus.playing
          default: ()
        }
      }
    }
    
    handleRemoteCommands()
  }
  
  func handleInterruption(notification: Notification) {
    guard let userInfo = notification.userInfo,
          let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
          let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
      return
    }
    switch type {
      case .began:
        pause()
      case .ended:
        guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
        let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
        if options.contains(.shouldResume) {
          listen()
        }
      default: ()
    }
  }
  
  func handleRemoteCommands() {
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
  
  func listen() {
    let playerItem = AVPlayerItem(url: audioURL)
    player.replaceCurrentItem(with: playerItem)
    do {
      try self.audioSession.setActive(true)
      player.play()
    } catch {
      print("Failed to activate audio session: \(error)")
    }
  }
  
  func pause() {
    player.pause()
  }
}
