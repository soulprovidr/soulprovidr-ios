import AVFoundation
import Foundation
import SwiftUI
import MediaPlayer

enum FetchError: Error {
    case badRequest
    case badJSON
}

enum InterruptionType: String {
    case began
    case ended
    case failed
}

struct RadioMetadata: Codable {
    var artist : String
    var cover : URL
    var duration : Double
    var end_at : String
    var id : Int
    var next_track : String
    var started_at : String
    var title : String
}

enum RadioStatus: String {
    case stopped
    case buffering
    case playing
}

@MainActor
class RadioPlayer: ObservableObject {
    @Published var metadata : RadioMetadata? = nil
    @Published var status = RadioStatus.stopped

    private var audioSession: AVAudioSession
    private var interruptionObserver: NSObjectProtocol!
    private var nowPlayingInfoCenter: MPNowPlayingInfoCenter
    private var player: AVPlayer?
    private var playerItemContext: UnsafeMutableRawPointer?
    private var remoteCommandCenter: MPRemoteCommandCenter

    private let radioMetadataUrl = "https://api.radioking.io/widget/radio/soulprovidr/track/current"
    private let radioStreamUrl = "https://www.radioking.com/play/soulprovidr"
    
    init() {
        audioSession = AVAudioSession.sharedInstance()
        nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        remoteCommandCenter = MPRemoteCommandCenter.shared()
        setupAudioSession()
        setupRemoteCommands()
    }

    func setupAudioSession() {
        do {
            try audioSession.setCategory(.playback, mode: .default, options: [.allowAirPlay, .allowBluetooth, .mixWithOthers])
        } catch {
            print("Failed to set audio session route sharing policy: \(error)")
        }
    }

    // Observe interruptions to the audio session.
    func setupInterruptionHandler() {
        interruptionObserver = NotificationCenter.default.addObserver(forName: AVAudioSession.interruptionNotification,
                                                                      object: audioSession,
                                                                      queue: .main) {
            [unowned self] notification in
            self.handleAudioSessionInterruption(notification: notification)
        }
    }
    
    func removeInterruptionHandler() {
        interruptionObserver = nil
    }
    
    func setupMetadataHandler() async
    throws {
        guard let url = URL(string: radioMetadataUrl) else { return }
        
        let (data, response) = try await URLSession.shared.data(for: URLRequest(url: url))
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw FetchError.badRequest }

        do {
            metadata = try JSONDecoder().decode(RadioMetadata.self, from: data)
            
            // Download cover art and update Now Playing info.
            print(metadata!.cover)
            let task = URLSession.shared.dataTask(with: metadata!.cover) { data, response, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async {
                    var nowPlayingInfo = [String: Any]()
                    nowPlayingInfo[MPNowPlayingInfoPropertyIsLiveStream] = true
                    nowPlayingInfo[MPNowPlayingInfoPropertyMediaType] = "audio"
                    nowPlayingInfo[MPMediaItemPropertyTitle] = self.metadata!.title
                    nowPlayingInfo[MPMediaItemPropertyArtist] = self.metadata!.artist
                    if let image = UIImage(data: data) {
                        nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { _ in
                            return image
                        }
                    }
                    self.nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
                }
            }
            
            task.resume()

            // Schedule next request.
            let nextTrackDate = ISO8601DateFormatter().date(from: metadata!.next_track)?.addingTimeInterval(10)
            Timer.scheduledTimer(withTimeInterval: nextTrackDate!.timeIntervalSinceNow, repeats: false) { _ in
                Task {
                    try? await self.setupMetadataHandler()
                }
            }
        } catch {
            throw FetchError.badJSON
        }
    }
    
    func setupRemoteCommands() {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        remoteCommandCenter.playCommand.addTarget { _ in
            self.listen()
            return MPRemoteCommandHandlerStatus.success
        }
        remoteCommandCenter.pauseCommand.addTarget { _ in
            self.stop()
            return MPRemoteCommandHandlerStatus.success
        }
    }

    func getPlayerItem() -> AVPlayerItem {
        let url = URL(string: radioStreamUrl)
        let asset = AVAsset(url: url!)
        let playerItem = AVPlayerItem(asset: asset)
        playerItem.preferredForwardBufferDuration = 0
        _ = playerItem.observe(\.status, options: [.new, .old], changeHandler: {
            (playerItem, change) in
            switch playerItem.status {
            case .readyToPlay:
                print("Ready to play!")
            case .failed:
                print("There was an error!")
            default: ()
                print("Some unknown thing happened!")
            }
        })
        return playerItem
    }

    func handleAudioSessionInterruption(notification: Notification) {
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

    func listen() {
        player = AVPlayer(playerItem: getPlayerItem())
        status = RadioStatus.playing
        player!.play()
        try? audioSession.setActive(true)
        setupInterruptionHandler()
        
    }

    func stop() {
        status = RadioStatus.stopped
        player!.pause()
        try? audioSession.setActive(false)
        removeInterruptionHandler()
    }
}
