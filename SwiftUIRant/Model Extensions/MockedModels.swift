//
//  MockedModels.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 09.09.22.
//

import Foundation
import SwiftDevRant

extension Rant {
    static func mocked() -> Self {
        return .init(
            id: 1,
            linkToRant: nil,
            voteState: .upvoted,
            score: 7,
            author: .init(
                id: 17,
                name: "Dr. Troll",
                score: 666,
                devRantSupporter: false,
                avatarSmall: .init(colorHex: "00ff00", imageUrlPath: nil),
                avatarLarge: .init(colorHex: "00ff00", imageUrlPath: nil)
            ),
            created: Date(),
            isEdited: true,
            isFavorite: false,
            text: "Lorem Ipsum Dolor Sit Amet.",
            linksInText: [],
            image: .mocked(),
            numberOfComments: 42,
            tags: ["tag1", "tag2"],
            weekly: nil,
            collaboration: nil
        )
    }
    
    static func mocked2() -> Self {
        return .init(
            id: 2,
            linkToRant: nil,
            voteState: .upvoted,
            score: 7,
            author: .init(
                id: 17,
                name: "Dr. Troll",
                score: 666,
                devRantSupporter: false,
                avatarSmall: .init(colorHex: "00ff00", imageUrlPath: nil),
                avatarLarge: .init(colorHex: "00ff00", imageUrlPath: nil)
            ),
            created: Date(),
            isEdited: true,
            isFavorite: false,
            text: "Lorem Ipsum Dolor Sit Amet.",
            linksInText: [],
            image: .mocked(),
            numberOfComments: 42,
            tags: ["tag1", "tag2"],
            weekly: nil,
            collaboration: nil
        )
    }
}

extension AttachedImage {
    static func mocked() -> Self {
        .init(
            url: "https://st2.depositphotos.com/3765753/5349/v/450/depositphotos_53491489-stock-illustration-example-rubber-stamp-vector-over.jpg",
            width: 600,
            height: 400
        )
    }
}
