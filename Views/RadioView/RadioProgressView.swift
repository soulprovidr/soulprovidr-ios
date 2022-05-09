import SwiftUI

struct RadioProgressView: View {
  var duration: Double
  var startedAt: String
  var status: RadioStatus
  
  @State private var elapsed = 0.0
  
  let progressTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
  
  var progressBarColour: Color {
    return status == RadioStatus.playing ? Color(UIColor(.blue)) : Color("ProgressBarFgColor")
  }
  
  var progressBarValue: Double {
    return min(1, Double(elapsed) / Double(duration))
  }
  
  func handleProgressTimer() {
    elapsed = min(abs(ISO8601DateFormatter().date(from: startedAt)!.addingTimeInterval(10).timeIntervalSinceNow), TimeInterval(duration))
  }
  
  func secondsToTime(s: Double) -> String {
    let minutes = Int(s) / 60 % 60
    let seconds = Int(s) % 60
    return String(format:"%02i:%02i", minutes, seconds)
  }
  
  var body: some View {
    Group {
      ProgressBarView(color: progressBarColour, value: progressBarValue)
        .onReceive(progressTimer) { _ in handleProgressTimer() }
      HStack {
        Text("\(secondsToTime(s: elapsed))")
          .font(.caption)
        Spacer()
        Text("\(secondsToTime(s: duration))")
          .font(.caption)
      }
    }.padding([.top], 10)
  }
}
