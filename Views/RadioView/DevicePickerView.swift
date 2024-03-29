import AVKit
import SwiftUI

struct DevicePickerView: UIViewRepresentable {
  func makeUIView(context: Context) -> UIView {
    let routePickerView = AVRoutePickerView()
    routePickerView.activeTintColor = UIColor(Color("AccentColor"))
    routePickerView.tintColor = UIColor(Color("FgColor"))
    return routePickerView
  }

  func updateUIView(_ uiView: UIView, context: Context) {

  }
}
