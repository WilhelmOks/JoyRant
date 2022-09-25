//
//  RantCommentView.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 21.09.22.
//

import SwiftUI
import SwiftRant

struct RantCommentView: View {
    @StateObject var viewModel: RantCommentViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VoteControl(
                isHorizontal: true,
                score: viewModel.voteController.displayedScore,
                isUpvoted: viewModel.voteController.showAsUpvoted,
                isDownvoted: viewModel.voteController.showAsDownvoted,
                upvoteAction: {
                    Task {
                        await viewModel.voteController.voteUp()
                    }
                },
                downvoteAction: {
                    Task {
                        await viewModel.voteController.voteDown()
                    }
                }
            )
            .disabled(viewModel.comment.voteState == .unvotable)
            
            Text(viewModel.comment.body)
                .font(baseSize: 15)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .foregroundColor(.primaryForeground)
            
            /*
            image()
            
            HStack {
                tags()
                
                Spacer()
                
                commentsCounter()
            }*/
        }
        .padding(10)
        .alert($viewModel.alertMessage)
        .background(Color.primaryBackground)
        .onReceive(viewModel.voteController.objectWillChange) {
            viewModel.objectWillChange.send()
        }
    }
}

struct RantCommentView_Previews: PreviewProvider {
    static var previews: some View {
        RantCommentView(
            viewModel: .init(
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
        )
    }
}
