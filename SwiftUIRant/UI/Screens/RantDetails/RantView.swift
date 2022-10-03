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
        content()
        .padding(.top, 10)
        .padding(.horizontal, 10)
        .alert($viewModel.alertMessage)
        .background(Color.primaryBackground)
        .onReceive(viewModel.voteController.objectWillChange) {
            viewModel.objectWillChange.send()
        }
        .onTapGesture(count: 2) {
            if viewModel.rant.isFromLoggedInUser {
                viewModel.editRant()
            } else {
                Task {
                    await viewModel.voteController.voteByContext()
                }
            }
        }
    }
    
    @ViewBuilder private func content() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            topArea(
                rant: viewModel.rant,
                voteController: viewModel.voteController
            )
            
            Text(viewModel.rant.text)
                .font(baseSize: 15)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .foregroundColor(.primaryForeground)
            
            image()
            
            HStack(alignment: .bottom, spacing: 10) {
                tags()
                
                Spacer()
                
                //commentsCounter()
                
                if viewModel.rant.isFromLoggedInUser {
                    deleteButton()
                    
                    editButton()
                } else {
                    reportButton()
                }
            }
        }
    }
    
    @ViewBuilder private func topArea(rant: Rant, voteController: VoteController) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                VoteControl(
                    isHorizontal: true,
                    score: voteController.displayedScore,
                    isUpvoted: voteController.showAsUpvoted,
                    isDownvoted: voteController.showAsDownvoted,
                    upvoteAction: {
                        Task {
                            await voteController.voteUp()
                        }
                    },
                    downvoteAction: {
                        Task {
                            await voteController.voteDown()
                        }
                    }
                )
                .disabled(rant.voteState == .unvotable)
                
                UserPanel(
                    avatar: rant.userAvatar,
                    name: rant.username,
                    score: rant.userScore,
                    isSupporter: rant.isUserSupporter
                )
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 6) {
                CreationTimeView(
                    createdTime: rant.createdTime,
                    isEdited: rant.isEdited
                )
                
                commentsCounter()
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
    
    @ViewBuilder private func reportButton() -> some View {
        Button {
            //TODO: ...
            viewModel.alertMessage = .presentedError(message: "Not implemented yet.")
        } label: {
            Text("Report")
                .font(baseSize: 11, weight: .medium)
                .multilineTextAlignment(.leading)
                .foregroundColor(.accentColor)
        }
    }
    
    @ViewBuilder private func editButton() -> some View {
        Button {
            viewModel.editRant()
        } label: {
            Text("Edit")
                .font(baseSize: 11, weight: .medium)
                .multilineTextAlignment(.leading)
                .foregroundColor(.accentColor)
        }
    }
    
    @ViewBuilder private func deleteButton() -> some View {
        Button {
            //TODO: ...
            viewModel.alertMessage = .presentedError(message: "Not implemented yet.")
        } label: {
            Text("Delete")
                .font(baseSize: 11, weight: .medium)
                .multilineTextAlignment(.leading)
                .foregroundColor(.accentColor)
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
