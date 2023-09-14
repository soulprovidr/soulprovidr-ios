import AVKit
import SwiftUI

struct DevicePickerView: UIViewRepresentable {
  @State var color: UIColor

  let routePickerView = AVRoutePickerView()
  
  func makeUIView(context: Context) -> UIView {
    routePickerView.tintColor = self.color
    return routePickerView
  }

  func updateUIView(_ uiView: UIView, context: Context) {
    routePickerView.tintColor = self.color
  }
}
