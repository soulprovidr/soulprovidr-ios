import SwiftUI

struct LoadingView: View {
    var err: RadioError? = nil
    var onTryAgainClick: (() -> Void)? = nil
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
            VStack {
                if err == nil {
                    ProgressView()
                } else {
                    Group {
                        Text("Something went wrong.")
                        Button("Try again") {
                            if onTryAgainClick != nil {
                                onTryAgainClick!()
                            }
                        }.offset(y: 10)
                    }
                }
            }
            .frame(width: 250, height: 60)
            Spacer()
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
