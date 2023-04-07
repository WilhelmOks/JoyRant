//
//  CommunityProjectRowView.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 07.04.23.
//

import SwiftUI

struct CommunityProjectRowView: View {
    let communityProject: CommunityProject
    
    var body: some View {
        VStack(spacing: 10) {
            HStack(alignment: .top) {
                Text(communityProject.title)
                    .font(baseSize: 17, weight: .semibold)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.primaryForeground)
                
                Spacer()
                
                CreationTimeView(
                    createdTime: communityProject.addedDate,
                    addedPrefix: true
                )
            }
            
            Text(communityProject.description)
                .font(baseSize: 15, weight: .regular)
                .multilineTextAlignment(.leading)
                .fillHorizontally(.leading)
                .foregroundColor(.primaryForeground)
            
            Text("Owner: \(communityProject.owner)")
                .font(baseSize: 15, weight: .regular)
                .multilineTextAlignment(.leading)
                .fillHorizontally(.leading)
                .foregroundColor(.primaryForeground)
                        
            linkProperty(name: "Website", link: communityProject.website)
            
            linkProperty(name: "Github", link: communityProject.github)
            
            linkProperty(name: "devRant URL", link: communityProject.relevantDevRantUrl)
            
            HStack(alignment: .bottom) {
                Text(propertiesText())
                    .font(baseSize: 12, weight: .medium)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.secondaryForeground)
                
                Spacer()
                
                Text(communityProject.active ? "active" : "not active")
                    .font(baseSize: 12, weight: .medium)
                    .multilineTextAlignment(.trailing)
                    .foregroundColor(.secondaryForeground)
            }
        }
    }
    
    @ViewBuilder private func linkProperty(name: String, link: String) -> some View {
        if let websiteUrl = URL(string: link) {
            HStack {
                Text("\(name): ")
                    .font(baseSize: 15, weight: .regular)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.primaryForeground)
                
                Link(communityProject.website, destination: websiteUrl)
                    .font(baseSize: 15, weight: .regular)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
        }
    }
    
    private func propertiesText() -> String {
        let properties: [String] = [
            communityProject.type,
            communityProject.operatingSystem,
            communityProject.language
        ]
        return String(properties.joined(separator: ", "))
    }
}

struct CommunityProjectRowView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityProjectRowView(communityProject: .mockedRandom())
            .padding(10)
    }
}
