//
//  URLImage.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 26.10.25.
//

import SwiftUI

struct URLImage: View {
    let url: String
    
    @State private var id = UUID()
    
    var body: some View {
        if let url = URL(string: url) {
            AsyncImage(
                url: url,
                transaction: Transaction(animation: .easeInOut)
            ) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .controlSize(.large)
                        .tint(.primaryForeground)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .frame(maxHeight: 1000)
                        .transition(.opacity)
                case .failure:
                    Button {
                        id = UUID()
                    } label: {
                        Image(systemName: "photo.trianglebadge.exclamationmark")
                            .imageScale(.large)
                            .foregroundStyle(Color.primaryForeground)
                    }
                @unknown default:
                    EmptyView()
                }
            }
            .id(id)
        }
    }
    
    private static let supportedExtensions: [String] = ["png", "jpg", "jpeg", "gif", "webp", "heic", "heif", "tiff", "tif", "bmp"]
    
    static func supports(url: String) -> Bool {
        guard let url = URL(string: url) else { return false }
        let fileExtension = url.pathExtension.lowercased()
        return supportedExtensions.contains(fileExtension)
    }
}

#Preview {
    URLImage(url: "https://gamersocialclub.ca/wp-content/uploads/2025/10/Yooka-Glitterglaze-Glacier-Pagies-157.png")
}

