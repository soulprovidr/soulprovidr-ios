import AVKit
import SwiftUI

struct DevicePickerView: UIViewRepresentable {
  func updateUIView(_ uiView: UIView, context: Context) {
    return;
  }
  
  func makeUIView(context: Context) -> UIView {
    let routeDetected = true;
    
    let routePickerView = AVRoutePickerView()
    routePickerView.tintColor = UIColor(Color("FgColor"))

    if !routeDetected {
      routePickerView.isHidden = true
    }

    return routePickerView
  }
}
