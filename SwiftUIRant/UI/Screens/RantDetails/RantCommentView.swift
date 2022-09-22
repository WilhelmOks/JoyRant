//
//  RantCommentView.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 21.09.22.
//

import SwiftUI
import SwiftRant

struct RantCommentView: View {
    let comment: Comment
    
    var body: some View {
        VStack(spacing: 20) {
            Text(comment.body)
        }
        .padding()
    }
}

struct RantCommentView_Previews: PreviewProvider {
    static var previews: some View {
        RantCommentView(
            comment: .init(
                id: 2,
                rantID: 1,
                body: "Lorem Ipsum",
                score: 56,
                createdTime: 0,
                voteState: .unvoted,
                links: nil, //TODO: test links
                userID: 1,
                username: "Saul Goodman",
                userScore: 43,
                userAvatar: .init(
                    backgroundColor: "00ff00", //TODO: test
                    avatarImage: nil //TODO: test
                ),
                isUserDPP: nil, //TODO: test
                attachedImage: nil //TODO: test
            )
        )
    }
}
