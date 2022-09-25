//
//  UserPanel.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 10.09.22.
//

import SwiftUI
import SwiftRant

struct UserPanel: View {
    let avatar: Rant.UserAvatar
    let name: String
    let score: Int
    
    var body: some View {
        HStack(spacing: 8) {
            UserAvatarView(avatar: avatar)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(name)
                    .font(baseSize: 15, weightDelta: 2)
                    .foregroundColor(.primaryForeground)
                
                Text(scoreText())
                    .font(baseSize: 11, weightDelta: 2)
                    .foregroundColor(.primaryBackground)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 1)
                    .background(Color.secondaryForeground)
                    .cornerRadius(5)
            }
        }
    }
    
    private func scoreText() -> String {
        score > 0 ? "+\(score)" : "\(score)"
    }
}

struct UserPanel_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            UserPanel(
                avatar: .init(
                    backgroundColor: "00ff00",
                    avatarImage: nil
                ),
                name: "Walter White",
                score: 123
            )
            
            UserPanel(
                avatar: .init(
                    backgroundColor: "00ff00",
                    avatarImage: nil
                ),
                name: "Walter White",
                score: -17
            )
            
            UserPanel(
                avatar: .init(
                    backgroundColor: "00ff00",
                    avatarImage: nil
                ),
                name: "Walter White",
                score: 0
            )
        }
    }
}
