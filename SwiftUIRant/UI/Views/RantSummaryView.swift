//
//  RantSummaryView.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 29.08.22.
//

import SwiftUI
import SwiftRant

struct RantSummaryView: View {
    let rant: RantInFeed?
    
    var body: some View {
        if let rant = rant {
            VStack(alignment: .leading) {
                Text(rant.text)
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                
                image(imageURL())
            }
        }
    }
    
    @ViewBuilder private func image(_ imageUrl: URL?) -> some View {
        if let imageUrl = imageUrl {
            AsyncImage(url: imageUrl) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                case .failure:
                    Image(systemName: "photo")
                @unknown default:
                    EmptyView()
                }
            }
        }
    }
    
    private func imageURL() -> URL? {
        guard let url = rant?.attachedImage?.url else { return nil }
        return URL(string: url)
    }
}

struct RantSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        RantSummaryView(rant: nil)
    }
}
