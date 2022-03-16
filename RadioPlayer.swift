import AVFoundation
import Foundation
import SwiftUI
import MediaPlayer

enum RadioError: Error {
    case metadataError
    case playbackError
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
    private let radioMetadataUrl = URL(string: "https://api.radioking.io/widget/radio/soulprovidr/track/current")
    private let radioStreamUrl = URL(string: "https://www.radioking.com/play/soulprovidr")

    @Published var elapsed : Double = 0.0
    @Published var metadata : RadioMetadata? = nil
    @Published var status = RadioStatus.stopped

    private var audioSession: AVAudioSession
    private var nowPlayingInfoCenter: MPNowPlayingInfoCenter
    private var remoteCommandCenter: MPRemoteCommandCenter

    private var interruptionObserver: NSObjectProtocol?
    private var timeControlStatusObserver: NSKeyValueObservation?

    private var player: AVPlayer?

    init() {
        audioSession = AVAudioSession.sharedInstance()
        nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        remoteCommandCenter = MPRemoteCommandCenter.shared()

        do {
            try audioSession.setCategory(.playback, mode: .default, options: [.allowAirPlay, .allowBluetooth])
        } catch {
            print("Failed to set audio session route sharing policy: \(error)")
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
        // We create a new player each time so we can start listening "live", rather than from the place we paused at.
        player = AVPlayer(url: radioStreamUrl!)
        
//        statusObserver = player!.observe(\.status, options: [.new]) { (player, change) in
//            let status = AVPlayer.Status(rawValue: player.status.rawValue)
//            switch (status) {
//            case .failed:
//                self.hasPlaybackErrorOccurred = true
//            default:
//                self.hasPlaybackErrorOccurred = false
//            }
//        }

        // Observe and react to changes in player status.
        timeControlStatusObserver = player!.observe(\.timeControlStatus, options: [.new]) { (player, change) in
            let timeControlStatus = AVPlayer.TimeControlStatus(rawValue: player.timeControlStatus.rawValue)
            switch timeControlStatus {
            // Destroy the player + associated observers when audio is paused.
            case .paused:
                self.status = RadioStatus.stopped
                try? self.audioSession.setActive(false, options: .notifyOthersOnDeactivation)
                self.player = nil
                self.interruptionObserver = nil
                self.timeControlStatusObserver = nil
            // Set status to 'buffering' when waiting.
            case .waitingToPlayAtSpecifiedRate:
                self.status = RadioStatus.buffering
            // Create observers once audio begins playing.
            case .playing:
                self.status = RadioStatus.playing
                self.interruptionObserver = NotificationCenter.default.addObserver(
                    forName: AVAudioSession.interruptionNotification,
                    object: self.audioSession,
                    queue: .main
                ) {
                    [unowned self] notification in
                    self.handleInterruption(notification: notification)
                }
            default: ()
            }
        }

        // Begin listening.
        try? audioSession.setActive(true)
        player!.playImmediately(atRate: 1.0)
    }

    func pause() {
        player!.pause()
    }

    func syncMetadata() async
    throws {
        let (data, response) = try await URLSession.shared.data(for: URLRequest(url: radioMetadataUrl!))
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw RadioError.metadataError }

        do {
            metadata = try JSONDecoder().decode(RadioMetadata.self, from: data)
            updateNowPlayingInfo(metadata: metadata!)
            // Schedule the next sync.
            let nextTrackDate = ISO8601DateFormatter().date(from: metadata!.next_track)?.addingTimeInterval(9)
            Timer.scheduledTimer(withTimeInterval: nextTrackDate!.timeIntervalSinceNow, repeats: false) { _ in
                Task {
                    // TODO: Improve error handling here.
                    try? await self.syncMetadata()
                }
            }
        } catch {
            throw RadioError.metadataError
        }
    }

    // Download cover art and update Now Playing info.
    func updateNowPlayingInfo(metadata: RadioMetadata) {
        let task = URLSession.shared.dataTask(with: metadata.cover) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async {
                var nowPlayingInfo = [String: Any]()
                nowPlayingInfo[MPNowPlayingInfoPropertyIsLiveStream] = true
                nowPlayingInfo[MPNowPlayingInfoPropertyMediaType] = "audio"
                nowPlayingInfo[MPMediaItemPropertyTitle] = metadata.title
                nowPlayingInfo[MPMediaItemPropertyArtist] = metadata.artist
                nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = "Soul Provider"
                if let image = UIImage(data: data) {
                    nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { _ in
                        return image
                    }
                }
                self.nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
            }
        }
        task.resume()
    }
}
