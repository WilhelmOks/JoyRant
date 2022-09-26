//
//  RantInFeed+Rant.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 26.09.22.
//

import SwiftRant

extension RantInFeed {
    func withData(fromRant rant: Rant) -> RantInFeed {
        .init(
            id: rant.id,
            text: rant.text,
            score: rant.score,
            createdTime: rant.createdTime,
            attachedImage: rant.attachedImage,
            commentCount: rant.commentCount,
            tags: rant.tags,
            voteState: rant.voteState,
            isEdited: rant.isEdited,
            link: rant.link,
            collabType: self.collabType,
            collabTypeLong: self.collabTypeLong,
            userID: rant.userID,
            username: rant.username,
            userScore: rant.userScore,
            userAvatar: rant.userAvatar,
            userAvatarLarge: rant.userAvatarLarge,
            isUserDPP: rant.isUserDPP
        )
    }
}
