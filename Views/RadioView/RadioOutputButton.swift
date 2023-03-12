import AVKit
import SwiftUI

struct OutputView: UIViewRepresentable {
  func makeUIView(context: Context) -> AVRoutePickerView {
    let v = AVRoutePickerView()
    v.sizeToFit()
    
    return v
  }
  
  func updateUIView(_ avRoutePicker: AVRoutePickerView, context: Context) {}
}

struct RadioOutputButton: View {
  var body: some View {
    OutputView()
  }
}
