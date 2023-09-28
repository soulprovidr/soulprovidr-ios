import Foundation
import MediaPlayer

let METADATA_URL = URL(string: Bundle.main.infoDictionary?["METADATA_URL"] as! String)

struct RadioMetadata: Codable {
  var artist: String
  var cover: URL
  var duration: Double
  var end_at: String
  var id: Int
  var next_track: String
  var started_at: String
  var title: String
}

extension RadioMetadata: Equatable {
  static func == (lhs: RadioMetadata, rhs: RadioMetadata) -> Bool {
    return lhs.id == rhs.id
  }
}

@MainActor
class RadioMetadataModel: ObservableObject {
  private let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
  
  @Published var err: RadioError? = nil
  @Published var metadata: RadioMetadata? = nil
  
  private func scheduleSync(waitForNextTrack: Bool) {
    var timeInterval: TimeInterval
    if waitForNextTrack {
      // Fetch metadata when next track starts.
      let nextTrackDate = ISO8601DateFormatter().date(from: metadata!.next_track)?.addingTimeInterval(9)
      timeInterval = nextTrackDate!.timeIntervalSinceNow
    } else {
      // Fetch metadata in 5 seconds.
      timeInterval = 5
    }
    Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { _ in
      Task {
        try? await self.sync()
      }
    }
  }
  
  func setNowPlayingInfo(metadata: RadioMetadata) {
    // Download cover art...
    let task = URLSession.shared.dataTask(with: metadata.cover) { data, response, error in
      guard let data = data, error == nil else { return }
      DispatchQueue.main.async {
        // ... then set the "now playing" information.
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

  func sync() async throws {
    do {
      err = nil
      let (data, response) = try await URLSession.shared.data(for: URLRequest(url: METADATA_URL!))
      guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw RadioError.metadataError }
      metadata = try JSONDecoder().decode(RadioMetadata.self, from: data)
      setNowPlayingInfo(metadata: metadata!)
      scheduleSync(waitForNextTrack: true)
    } catch {
      err = RadioError.metadataError
      // If this is not the first time we are fetching the metadata, retry shortly.
      if metadata != nil {
        scheduleSync(waitForNextTrack: false)
      }
    }
  }
}
