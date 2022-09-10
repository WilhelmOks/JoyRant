//
//  MockedModels.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 09.09.22.
//

import Foundation
import SwiftRant

extension RantInFeed {
    static func mocked() -> Self {
        return .init(
            id: 1,
            text: "Lorem Ipsum Dolor Sit Amet.",
            score: 7,
            createdTime: 100,
            attachedImage: .mocked(),
            commentCount: 42,
            tags: ["tag1", "tag2"],
            voteState: .unvoted,
            isEdited: true,
            link: nil,
            collabType: nil,
            collabTypeLong: nil,
            userID: 17,
            username: "Dr. Troll",
            userScore: 666,
            userAvatar: .init(
                backgroundColor: "00ff00",
                avatarImage: nil
            ),
            userAvatarLarge: .init(
                backgroundColor: "00ff00",
                avatarImage: nil
            ),
            isUserDPP: nil
        )
    }
}

extension Rant.AttachedImage {
    static func mocked() -> Self {
        .init(
            url: "https://st2.depositphotos.com/3765753/5349/v/450/depositphotos_53491489-stock-illustration-example-rubber-stamp-vector-over.jpg",
            width: 600,
            height: 400
        )
    }
}
