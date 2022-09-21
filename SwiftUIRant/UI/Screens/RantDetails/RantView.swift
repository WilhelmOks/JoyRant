//
//  RantView.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 21.09.22.
//

import SwiftUI
import SwiftRant

struct RantView: View {
    let rant: Rant
    
    var body: some View {
        Text(rant.text)
    }
}

struct RantView_Previews: PreviewProvider {
    static var previews: some View {
        RantView(
            rant: .init(
                weekly: nil, //TODO: test
                id: 1,
                text: "Lorem ipsum dolor sit a rant",
                score: 83,
                createdTime: 0, //TODO: use something realistic
                attachedImage: nil, //TODO: test
                commentCount: 2,
                tags: ["rant", "js suxx"],
                voteState: 0, //TODO: enum
                isEdited: false, //TODO: test
                link: nil, //TODO: test
                collabTypeLong: nil, //TODO: test
                collabDescription: nil, //TODO: test
                collabTechStack: nil, //TODO: test
                collabTeamSize: nil, //TODO: test
                collabURL: nil, //TODO: test
                userID: 2,
                username: "Spongeblob",
                userScore: 666,
                userAvatar: .init(
                    backgroundColor: "00ff00", //TODO: test
                    avatarImage: nil //TODO: test
                ),
                userAvatarLarge: .init(
                    backgroundColor: "00ff00", //TODO: test
                    avatarImage: nil //TODO: test
                ),
                isUserDPP: nil //TODO: test
            )
        )
    }
}
