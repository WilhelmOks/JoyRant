//
//  ProfileView.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 19.11.22.
//

import SwiftUI
import SwiftRant
import CachedAsyncImage

struct ProfileView: View {
    @StateObject var viewModel: ProfileViewModel
    
    private let emptyBgColor = Color.gray.opacity(0.3)
        
    var profile: Profile {
        viewModel.profile ?? viewModel.placeholderProfile
    }
    
    var body: some View {
        content()
            .alert($viewModel.alertMessage)
            .navigationTitle(viewModel.title)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(viewModel.title).fontWeight(.semibold)
                }
            }
    }
    
    @ViewBuilder private func content() -> some View {
        VStack(spacing: 0) {
            header()
                .frame(height: 250)
                .overlay(alignment: .topLeading) {
                    score()
                        .padding(10)
                }
            
            //Text(profile.username)
            
            Spacer()
        }
        .if(!viewModel.isLoaded) {
            $0.redacted(reason: .placeholder)
        }
    }
    
    @ViewBuilder private func score() -> some View {
        let score = profile.score
        let scoreText = score > 0 ? "+\(score)" : "\(score)"
        
        Text(scoreText)
            .font(baseSize: 13, weightDelta: 2)
            .foregroundColor(.primaryForeground)
            .padding(.vertical, 1)
            .padding(.horizontal, 5)
            .background {
                RoundedRectangle(cornerRadius: 5)
                    .foregroundColor(.secondaryBackground)
            }
    }
    
    @ViewBuilder private func header() -> some View {
        if let url = avatarUrl() {
            CachedAsyncImage(url: url, urlCache: .profileImageCache) { phase in
                switch phase {
                case .empty:
                    ZStack {
                        userColor()
                        
                        ProgressView()
                            .foregroundColor(.primaryForeground)
                            .tint(.primaryForeground)
                            .accentColor(.primaryForeground)
                    }
                case .success(let image):
                    ZStack {
                        userColor()
                        
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                case .failure:
                    Image(systemName: "photo")
                @unknown default:
                    EmptyView()
                }
            }
        } else {
            userColor()
        }
    }
    
    private func avatarUrl() -> URL? {
        profile.avatar.avatarImage.flatMap { path in
            URL(string: "https://avatars.devrant.com/\(path)")
        }
    }
    
    private func userColor() -> Color {
        Color(hexString: profile.avatar.backgroundColor) ?? emptyBgColor
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(viewModel: .init(userId: 0))
    }
}
