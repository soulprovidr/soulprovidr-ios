import GoogleCast
import SwiftUI

struct ChromecastButtonView: UIViewRepresentable {
  func makeUIView(context: Context) -> UIView {
    let castButton = GCKUICastButton()
    castButton.tintColor = UIColor(Color("FgColor"))
    return castButton
  }


  func updateUIView(_ uiView: UIView, context: Context) {
  
  }

}
