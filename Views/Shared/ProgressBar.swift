import SwiftUI

struct ProgressBarView: View {
  var color: Color
  var value: Double
  
  var body: some View {
    Rectangle()
      .fill(.clear)
      .frame(height: 4)
      .background {
        GeometryReader { geometry in
          let width = value * geometry.size.width
          ZStack(alignment: .leading) {
            Rectangle()
              .fill(Color("ProgressBarBgColor"))
              .frame(height: 1)
            RoundedRectangle(cornerRadius: 2)
              .fill(color)
              .frame(width: width, height: 4)
          }.frame(height: 4)
        }
      }
  }
}

struct ProgressBarView_Previews: PreviewProvider {
  static var previews: some View {
    LoadingView()
  }
}
