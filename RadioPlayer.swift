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

    private var player: AVPlayer?
    private let radioStreamUrl = "https://www.radioking.com/play/soulprovidr"

    func listen() {
        let url = URL(string: radioStreamUrl)
        self.player = AVPlayer(url: url!)
        self.player!.play()
    }

    func stop() {
        self.player!.pause()
    }
}
