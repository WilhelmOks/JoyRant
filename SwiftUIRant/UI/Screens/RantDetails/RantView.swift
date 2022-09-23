//
//  RantView.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 21.09.22.
//

import SwiftUI
import SwiftRant

struct RantView: View {
    @StateObject var viewModel: RantViewModel
    
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
            .disabled(viewModel.rant.voteState == .unvotable)
            
            Text(viewModel.rant.text)
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

struct RantView_Previews: PreviewProvider {
    static var previews: some View {
        RantView(
            viewModel: .init(
                rant: .init(
                    weekly: nil, //TODO: test
                    id: 1,
                    text: "Lorem ipsum dolor sit a rant",
                    score: 83,
                    createdTime: 0, //TODO: use something realistic
                    attachedImage: nil, //TODO: test
                    commentCount: 2,
                    tags: ["rant", "js suxx"],
                    voteState: .unvoted,
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
        )
    }
}
