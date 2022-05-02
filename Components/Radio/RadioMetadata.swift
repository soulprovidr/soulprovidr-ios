import Foundation

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

extension RadioMetadata: Equatable {
    static func == (lhs: RadioMetadata, rhs: RadioMetadata) -> Bool {
        return lhs.id == rhs.id
    }
}
