//
//  UserAvatarView.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 25.09.22.
//

import SwiftUI
import CachedAsyncImage
import SwiftDevRant

/// Shows the image of the user avatar in a circle shape.
/// Contrary to the official app, the image is not green but gray if there is no avatar.
struct UserAvatarView: View {
    let avatar: User.Avatar
    var size: CGFloat = 44
    
    private let emptyBgColor = Color.gray.opacity(0.3)
    
    var body: some View {
        content()
            .clipShape(Circle())
            .frame(width: size, height: size)
    }
    
    @ViewBuilder private func content() -> some View {
        if let url = avatar.imageUrl {            
            CachedAsyncImage(url: url, urlCache: .userAvatarCache) { phase in
                switch phase {
                case .empty:
                    ZStack {
                        Rectangle()
                            .fill(userColor())
                        
                        ProgressView()
                    }
                case .success(let image):
                    image
                        .resizable()
                case .failure:
                    Image(systemName: "photo")
                        .resizable()
                        .padding()
                        .background(emptyBgColor)
                @unknown default:
                    EmptyView()
                }
            }
        } else {
            userColor()
        }
    }
    
    private func userColor() -> Color {
        Color(hexString: avatar.colorHex) ?? emptyBgColor
    }
}

struct UserAvatarView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            UserAvatarView(
                avatar: .init(
                    colorHex: "66dddd",
                    imageUrlPath: "v-37_c-3_b-6_g-m_9-1_1-4_16-3_3-4_8-1_7-1_5-1_12-4_6-102_10-1_2-39_22-2_15-10_11-1_4-1.jpg"
                )
            )
            
            UserAvatarView(
                avatar: .init(
                    colorHex: "66dddd",
                    imageUrlPath: nil
                )
            )
            
            UserAvatarView(
                avatar: .init(
                    colorHex: "",
                    imageUrlPath: nil
                )
            )
        }
    }
}
