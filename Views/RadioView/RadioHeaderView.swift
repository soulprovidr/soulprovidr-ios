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
    var body: some View {
        HStack {
            HStack {
                LogoView(size: 32)
                Text("SOUL PROVIDER")
                    .font(.system(size: 16, weight: .bold))
                    .offset(x: 4)
            }
            Spacer()
            HStack {
                LiveIcon(size: 6)
                    .offset(x: 2)
                Text("LIVE")
                    .font(.system(size: 14, weight: .semibold))
            }.frame(alignment: .center)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
