import Foundation
import SwiftUI

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

@MainActor
class RadioMetadataFetcher: ObservableObject {
    @Published var radioMetadata : RadioMetadata? = nil

    let radioMetadataUrl = "https://api.radioking.io/widget/radio/soulprovidr/track/current"

    enum FetchError: Error {
        case badRequest
        case badJSON
    }

    @available(iOS 15.0, *)
    func fetch() async
    throws {
        guard let url = URL(string: radioMetadataUrl) else { return }
        
        let (data, response) = try await URLSession.shared.data(for: URLRequest(url: url))
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw FetchError.badRequest }

        do {
            radioMetadata = try JSONDecoder().decode(RadioMetadata.self, from: data)
            let nextTrackDate = ISO8601DateFormatter().date(from: radioMetadata!.next_track)?.addingTimeInterval(10)
            Timer.scheduledTimer(withTimeInterval: nextTrackDate!.timeIntervalSinceNow, repeats: false) { _ in
                Task {
                    try? await self.fetch()
                }
            }
        } catch {
            throw FetchError.badJSON
        }
    }
}
