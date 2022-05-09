import SwiftUI

struct RadioMetadataView: View {
  var metadata: RadioMetadata
  var status: RadioStatus
  
  var body: some View {
    VStack {
      RadioCoverImageView(cover: metadata.cover)
      HStack {
        VStack {
          Text(metadata.title)
            .font(.system(size: 24, weight: .bold))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 10)
            .lineLimit(1)
          Text(metadata.artist)
            .font(.system(size: 20))
            .frame(maxWidth: .infinity, alignment: .leading)
            .lineLimit(1)
        }
        Spacer()
        (status == RadioStatus.buffering ? ProgressView() : nil)
      }
    }
  }
}
