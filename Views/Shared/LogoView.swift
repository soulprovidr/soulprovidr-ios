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
    var body: some View {
        Image(getLogoImage(modifier: modifier))
            .resizable()
            .frame(width: size, height: size)
            .scaledToFit()
            .clipShape(Circle())
    }
}

struct LogoView_Previews: PreviewProvider {
    static var previews: some View {
        LogoView()
        LogoView(modifier: .surprised)
    }
}
