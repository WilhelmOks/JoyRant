//
//  PostedImage.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 10.09.22.
//

import SwiftUI
import CachedAsyncImage
import SwiftRant

struct PostedImage: View {
    let image: Rant.AttachedImage
    
    var body: some View {
        CachedAsyncImage(url: imageURL(), urlCache: .postedImageCache) { phase in
            switch phase {
            case .empty:
                ZStack {
                    let aspectRatio = CGFloat(image.width) / CGFloat(image.height)
                    
                    Rectangle()
                        .fill(Color.clear)
                        .aspectRatio(aspectRatio, contentMode: .fit)
                    
                    ProgressView()
                }
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
    
    private func imageURL() -> URL? {
        return URL(string: image.url)
    }
}

struct PostedImage_Previews: PreviewProvider {
    static var previews: some View {
        PostedImage(image: .mocked())
    }
}
