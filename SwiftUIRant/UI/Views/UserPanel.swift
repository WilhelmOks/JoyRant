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
    
    var body: some View {
        UserAvatarView(avatar: avatar)
    }
}

struct UserPanel_Previews: PreviewProvider {
    static var previews: some View {
        UserPanel(
            avatar: .init(
                backgroundColor: "00ff00",
                avatarImage: nil
            )
        )
    }
}
