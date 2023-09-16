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
    ? AnyTransition.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading).combined(with: .opacity))
    : AnyTransition.asymmetric(insertion: AnyTransition.identity, removal: .move(edge: .leading).combined(with: .opacity))
  }

  func loadImage(url: URL, action: (UIImage) -> Void) async throws -> Void {
    if let (data, _) = try? await URLSession.shared.data(from: url) {
      return action(UIImage(data: data)!)
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
    }
    .onAppear() {
      Task {
        try? await loadImage(url: cover) { image in
          images.append(image)
        }
        // TODO: handle error (placeholder?)
      }
    }
    .onChange(of: cover) { cover in
      Task {
        try? await loadImage(url: cover) { image in
          withAnimation(.easeInOut(duration: 0.3)) {
            images.append(image)
            images.remove(at: 0)
          }
        }
      }
    }
  }
}
