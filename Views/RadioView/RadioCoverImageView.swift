import SwiftUI

enum RadioCoverError: Error {
   case failed
}

struct RadioCoverImageView: View {
    var cover: URL

    @State var images: [UIImage] = []
    @State var isInitialized = false

    var transition: AnyTransition {
        isInitialized
            ? AnyTransition.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading))
            : AnyTransition.asymmetric(insertion: AnyTransition.identity, removal: .move(edge: .leading))
    }

    func loadImageFromUrl(url: URL) throws -> UIImage {
        if let data = try? Data(contentsOf: url) {
            return UIImage(data: data)!
        }
        throw RadioCoverError.failed
    }

    var body: some View {
        ZStack {
            if (images.count == 0) {
                Rectangle()
                    .fill(.clear)
                    .aspectRatio(1.0, contentMode: .fit)
            }
            ForEach(images, id: \.self) { uiImage in
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(4)
                    .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.10), radius: 5)
                    .opacity(isInitialized ? 1 : 0)
                    .frame(idealWidth: 400)
                    .transition(transition)
                    .onAppear {
                        withAnimation {
                            isInitialized = true
                        }
                    }
            }
            .animation(.default, value: images.count)
        }
        .onAppear() {
            if let image = try? loadImageFromUrl(url: cover) {
                images.append(image)
            }
        }
        .onChange(of: cover) { cover in
            withAnimation {
                if let image = try? loadImageFromUrl(url: cover) {
                    images.append(image)
                    images.remove(at: 0)
                }
            }
        }
    }
}
