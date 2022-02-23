import AVFoundation
import Foundation
import SwiftUI

enum RadioPlayerStatus: String {
    case stopped
    case buffering
    case playing
}

@MainActor
class RadioPlayer: ObservableObject {
    @Published var status = RadioPlayerStatus.stopped

    private var audioSession: AVAudioSession
    private var player: AVPlayer?
    private let radioStreamUrl = "https://www.radioking.com/play/soulprovidr"
    
    init() {
        audioSession = AVAudioSession.sharedInstance()
        initAudioSession()
    }

    @objc func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                  return
              }
        switch type {
        case .began:
            stop()
        case .ended:
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                listen()
            }
        default: ()
        }
    }

    func initAudioSession() {
        do {
            try audioSession.setCategory(.playback, mode: .default, options: [.allowAirPlay, .allowBluetooth, .mixWithOthers])
        } catch {
            print("Failed to set audio session route sharing policy: \(error)")
        }
    }

    func initNotifications() {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification, object: audioSession)
    }

    func listen() {
        let url = URL(string: radioStreamUrl)
        player = AVPlayer(url: url!)
        player!.play()
        try? audioSession.setActive(true)
        status = RadioPlayerStatus.playing
    }

    func stop() {
        status = RadioPlayerStatus.stopped
        player!.pause()
        try? audioSession.setActive(false)
    }
}
