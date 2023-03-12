import SwiftUI


struct LogoView: View {
  var size: CGFloat = 45
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
    Image("SPLogo")
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
  }
}
