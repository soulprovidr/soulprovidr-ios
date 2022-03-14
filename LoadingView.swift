import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Image("SPLogoRounded")
                    .resizable()
                    .frame(width: 45, height: 45)
                    .scaledToFill()
                Text("SOUL PROVIDER")
                    .font(.system(size: 22, weight: .bold))
                    .offset(x: 7)
                Spacer()
            }
            ProgressView()
                .offset(y: 24)
            Spacer()
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
