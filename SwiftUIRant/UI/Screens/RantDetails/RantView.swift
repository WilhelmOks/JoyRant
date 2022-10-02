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
            HStack(alignment: .top) {
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
                    
                    UserPanel(
                        avatar: viewModel.rant.userAvatar,
                        name: viewModel.rant.username,
                        score: viewModel.rant.userScore,
                        isSupporter: viewModel.rant.isUserSupporter
                    )
                }
                
                Spacer()
                
                CreationTimeView(
                    createdTime: viewModel.rant.createdTime,
                    isEdited: viewModel.rant.isEdited
                )
            }
            
            Text(viewModel.rant.text)
                .font(baseSize: 15)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .foregroundColor(.primaryForeground)
            
            image()
            
            HStack(alignment: .bottom) {
                tags()
                
                Spacer()
                
                commentsCounter()
            }
        }
        .padding(.top, 10)
        .padding(.horizontal, 10)
        .alert($viewModel.alertMessage)
        .background(Color.primaryBackground)
        .onReceive(viewModel.voteController.objectWillChange) {
            viewModel.objectWillChange.send()
        }
        .onTapGesture(count: 2) {
            Task {
                //TODO: edit instead of vote if it's the rant of the logged in user
                await viewModel.voteController.voteByContext()
            }
        }
    }
    
    @ViewBuilder private func image() -> some View {
        if let image = viewModel.rant.attachedImage {
            PostedImage(image: image)
        }
    }
    
    @ViewBuilder private func tags() -> some View {
        let tags = viewModel.rant.tags.joined(separator: ", ")
        
        Text(tags)
            .font(baseSize: 11, weight: .medium)
            .multilineTextAlignment(.leading)
            .foregroundColor(.secondaryForeground)
    }
    
    @ViewBuilder private func commentsCounter() -> some View {
        HStack(spacing: 3) {
            Image(systemName: "bubble.right")
                .font(baseSize: 11)
            
            Text("\(viewModel.rant.commentCount)")
                .font(baseSize: 11, weight: .medium)
        }
        .foregroundColor(.secondaryForeground)
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
                    //createdTime: Int(Date().addingTimeInterval(60 * 60 * 24 * -15).timeIntervalSince1970),
                    createdTime: Int(Date().addingTimeInterval(-15).timeIntervalSince1970),
                    attachedImage: nil,
                    commentCount: 2,
                    tags: ["rant", "js suxx"],
                    voteState: .unvoted,
                    isEdited: true,
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
                        backgroundColor: "00cc00",
                        avatarImage: nil
                    ),
                    userAvatarLarge: .init(
                        backgroundColor: "00cc00",
                        avatarImage: nil
                    ),
                    isUserDPP: nil
                )
            )
        )
    }
}
