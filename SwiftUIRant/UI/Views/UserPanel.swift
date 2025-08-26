//
//  UserPanel.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 10.09.22.
//

import SwiftUI
import SwiftDevRant

struct UserPanel: View {
    let avatar: User.Avatar
    let name: String
    let score: Int
    let isSupporter: Bool
    var compact = false
    var opaqueBackground: Bool = true
    
    var body: some View {
        Group {
            if compact {
                HStack(spacing: 8) {
                    UserAvatarView(avatar: avatar, size: 24)
                    
                    nameView()
                    
                    scoreView()
                }
            } else {
                HStack(spacing: 8) {
                    UserAvatarView(avatar: avatar)
                    
                    VStack(alignment: .leading, spacing: 3) {
                        nameView()
                        
                        scoreView()
                    }
                }
            }
        }
        .background(opaqueBackground ? Color.primaryBackground : nil)
    }
    
    @ViewBuilder private func nameView() -> some View {
        Text(name)
            .font(baseSize: 16, weightDelta: 2)
            .foregroundColor(.primaryForeground)
    }
    
    @ViewBuilder private func scoreView() -> some View {
        HStack(spacing: 4) {
            Text(scoreText())
                .font(baseSize: 12, weightDelta: 2)
                .foregroundColor(.primaryForeground)
                .padding(.horizontal, 5)
                .padding(.vertical, 1)
                .background(Color.secondaryBackground)
                .cornerRadius(5)
            
            if isSupporter {
                Text("++")
                    .font(baseSize: 12, weightDelta: 3)
                    .offset(y: -0.5)
                    .foregroundColor(.primaryForeground)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 1)
                    .background(userColor())
                    .cornerRadius(5)
            }
        }
    }
    
    private func scoreText() -> String {
        score > 0 ? "+\(score)" : "\(score)"
    }
    
    private func userColor() -> Color {
        Color(hexString: avatar.colorHex) ?? .secondaryForeground
    }
}

struct UserPanel_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            UserPanel(
                avatar: .init(
                    colorHex: "88ee88",
                    imageUrlPath: nil
                ),
                name: "Walter White",
                score: 123,
                isSupporter: true,
                compact: true
            )
            
            UserPanel(
                avatar: .init(
                    colorHex: "88ee88",
                    imageUrlPath: nil
                ),
                name: "Walter White",
                score: 123,
                isSupporter: true            )
            
            UserPanel(
                avatar: .init(
                    colorHex: "88ee88",
                    imageUrlPath: nil
                ),
                name: "Walter White",
                score: 123,
                isSupporter: false
            )
            
            UserPanel(
                avatar: .init(
                    colorHex: "88ee88",
                    imageUrlPath: nil
                ),
                name: "Walter White",
                score: -17,
                isSupporter: false
            )
            
            UserPanel(
                avatar: .init(
                    colorHex: "88ee88",
                    imageUrlPath: nil
                ),
                name: "Walter White",
                score: 0,
                isSupporter: false
            )
        }
        //.redacted(reason: .placeholder)
    }
}
