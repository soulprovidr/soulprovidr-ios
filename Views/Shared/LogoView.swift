import SwiftUI

enum LogoModifier {
  case classic
  case surprised
}

func getLogoImage(modifier: LogoModifier) -> String {
  switch modifier {
    case .classic:
      return "SPLogo"
    case .surprised:
      return "SPLogoSurprised"
  }
}

struct LogoView: View {
  var size: CGFloat = 45
  var modifier: LogoModifier = .classic
  var onTapGesture: (() -> Void)?
  
  @GestureState private var isBeingTouched = false
  
  var currentSize: CGFloat {
    return isBeingTouched ? 1.1 : 1
  }
  
  var body: some View {
    let tap = DragGesture(minimumDistance: 0)
      .onChanged { _ in
        if isBeingTouched == false, let handleTapGesture = onTapGesture {
          handleTapGesture()
        }
      }
      .updating($isBeingTouched) { (_, isBeingTouched, _) in
        withAnimation {
          isBeingTouched = true
        }
      }
    Image(getLogoImage(modifier: modifier))
      .resizable()
      .frame(width: size, height: size)
      .clipShape(Circle())
      .scaleEffect(currentSize)
      .animation(.easeIn(duration: 0.1), value: currentSize)
      .gesture(tap)
  }
}

struct LogoView_Previews: PreviewProvider {
  static var previews: some View {
    LogoView()
    LogoView(modifier: .surprised)
  }
}
