import SwiftUI

struct LoadingView: View {
    var err: RadioError? = nil
    var onTryAgainClick: (() -> Void)? = nil
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Image("SPLogoRounded")
                        .resizable()
                        .frame(width: 45, height: 45)
                        .scaledToFit()
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
                            if onTryAgainClick != nil {
                                onTryAgainClick!()
                            }
                        }.offset(y: 10)
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
