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
