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
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                header()
                    .frame(height: 250)
                    .overlay(alignment: .topLeading) {
                        score()
                            .padding(10)
                    }
                    .overlay(alignment: .topTrailing) {
                        joinedOnDate()
                            .padding(10)
                    }
                
                infoArea()
                    .fillHorizontally(.leading)
                    .padding(.horizontal, 10)
            }
            .if(!viewModel.isLoaded) {
                $0.redacted(reason: .placeholder)
            }
        }
    }
    
    @ViewBuilder private func infoArea() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            infoRow(iconName: "person", text: profile.about)
            infoRow(iconName: "s.circle", text: profile.skills)
            infoRow(iconName: "mappin.and.ellipse", text: profile.location)
            if let website = profile.website {
                infoRow(iconName: "globe", text: website) //TODO: open as link
            }
            infoRow(iconName: "g.circle", text: profile.github) //TODO: open as link. (the text is just the user's github name)
            
            //TODO: hide empty
            //TODO: change icons
        }
    }
    
    @ViewBuilder private func infoRow(iconName: String, text: String) -> some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: iconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .foregroundColor(.primaryForeground)
                .alignmentGuide(VerticalAlignment.center) { dim in
                    dim[VerticalAlignment.center] + 5
                }
            
            Text(text)
                .font(baseSize: 16)
                .multilineTextAlignment(.leading)
                .foregroundColor(.primaryForeground)
                .alignmentGuide(VerticalAlignment.center) { dim in
                    dim[.firstTextBaseline]
                }
        }
    }
    
    @ViewBuilder private func score() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            if profile.isUserDPP == 1 {
                Text("Supporter")
                    .font(baseSize: 13, weightDelta: 2)
                    .foregroundColor(.primaryForeground)
                    .padding(.vertical, 1)
                    .padding(.horizontal, 5)
                    .background {
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundColor(.secondaryBackground)
                    }
            }
            
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
    }
    
    @ViewBuilder private func joinedOnDate() -> some View {
        let formattedDate = AbsoluteDateFormatter.shared.string(fromSeconds: profile.createdTime)
        Text("Joined on\n\(formattedDate)")
            .font(baseSize: 13, weightDelta: 2)
            .multilineTextAlignment(.trailing)
            .foregroundColor(.white)
    }
    
    @ViewBuilder private func header() -> some View {
        if let url = avatarUrl() {
            CachedAsyncImage(url: url, urlCache: .profileImageCache) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .fillHorizontally()
                    .background(userColor())
            } placeholder: {
                userColor()
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
        ProfileView(viewModel: .init(userId: 0, mocked: true))
    }
}
