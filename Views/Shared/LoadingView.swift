import SwiftUI

struct LoadingView: View {
  var err: RadioError? = nil
  var onTryAgainPress: (() -> Void)? = nil
  var body: some View {
    ZStack {
      VStack {
        Spacer()
        HStack {
          Spacer()
          LogoView(size: 45)
          Text("SOUL PROVIDER")
            .font(.system(size: 22, weight: .bold))
            .offset(x: 7)
          Spacer()
        }
        Spacer()
      }
      VStack {
        Spacer()
        VStack {
          if err == nil {
            ProgressView()
          } else {
            Text("Something went wrong.")
            Button("Try again") {
              onTryAgainPress!()
            }.offset(y: 10)
              .foregroundColor(.blue)
          }
        }.frame(height: 100)
      }
    }
  }
}

struct LoadingView_Previews: PreviewProvider {
  static var previews: some View {
    LoadingView()
  }
}
