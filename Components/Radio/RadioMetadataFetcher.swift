import Foundation
import MediaPlayer

@MainActor
class RadioMetadataFetcher: ObservableObject {
    private let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
    private let radioMetadataUrl = URL(string: "https://api.radioking.io/widget/radio/soulprovidr/track/current")

    @Published var err: RadioError? = nil
    @Published var metadata: RadioMetadata? = nil
    
    func fetch() async throws {
        do {
            err = nil
            let (data, response) = try await URLSession.shared.data(for: URLRequest(url: radioMetadataUrl!))
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw RadioError.metadataError }
            metadata = try JSONDecoder().decode(RadioMetadata.self, from: data)
            setNowPlayingInfo(metadata: metadata!)
            scheduleFetch(waitForNextTrack: true)
        } catch {
            err = RadioError.metadataError
            // If this is not the first time we are fetching the metadata, retry shortly.
            if metadata != nil {
                scheduleFetch(waitForNextTrack: false)
            }
        }
    }

    func scheduleFetch(waitForNextTrack: Bool) {
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
                try? await self.fetch()
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
}
