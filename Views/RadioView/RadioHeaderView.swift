import SwiftUI

struct LiveIcon: View {
    let size: CGFloat

    @State var isVisible = true

    let timer = Timer.publish(every: 0.75, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Circle()
            .fill(Color(UIColor(.red)))
            .frame(width: size, height: size, alignment: .center)
            .opacity(isVisible ? 1 : 0)
            .onReceive(timer) { _ in
                withAnimation {
                    isVisible = !isVisible
                }
            }
    }
}

struct RadioHeaderView: View {
    var onTapGesture: (() -> Void)?
    var body: some View {
        HStack {
                HStack {
                    LiveIcon(size: 8)
                        .padding(.trailing, 2)
                    Text("Live")
                        .font(.system(size: 24, weight: .semibold))
                }.frame(alignment: .center)
            Spacer()
            LogoView(size: 32, onTapGesture: onTapGesture)
        }
        .padding(.top, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
