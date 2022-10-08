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
        content()
        .padding(.top, 10)
        .padding(.horizontal, 10)
        .alert($viewModel.alertMessage)
        .background(Color.primaryBackground)
        .onReceive(viewModel.voteController.objectWillChange) {
            viewModel.objectWillChange.send()
        }
        .onTapGesture(count: 2) {
            if viewModel.comment.isFromLoggedInUser {
                viewModel.editComment()
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
                comment: viewModel.comment,
                voteController: viewModel.voteController
            )
            
            Text(viewModel.comment.body)
                .font(baseSize: 15)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .foregroundColor(.primaryForeground)
            
            image()
            
            HStack(alignment: .bottom, spacing: 10) {
                replyButton()
                
                Spacer()
                
                if viewModel.comment.isFromLoggedInUser {
                    deleteButton()
                    
                    editButton()
                } else {
                    //reportButton()
                }
            }
        }
    }
    
    @ViewBuilder private func topArea(comment: Comment, voteController: VoteController) -> some View {
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
                .disabled(comment.voteState == .unvotable)
                
                UserPanel(
                    avatar: comment.userAvatar,
                    name: comment.username,
                    score: comment.userScore,
                    isSupporter: comment.isUserSupporter
                )
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 6) {
                CreationTimeView(
                    createdTime: comment.createdTime,
                    isEdited: false
                )
                
                /*
                if viewModel.comment.isFromLoggedInUser {
                    deleteButton()
                    
                    editButton()
                } else {
                    reportButton()
                }
                
                replyButton()
                */
            }
        }

    }
    
    @ViewBuilder private func image() -> some View {
        if let image = viewModel.comment.attachedImage {
            PostedImage(image: image)
        }
    }
        
    @ViewBuilder private func replyButton() -> some View {
        Button {
            viewModel.alertMessage = .presentedError(message: "Not implemented yet.")
        } label: {
            Text("Reply")
                .font(baseSize: 11, weight: .medium)
                .multilineTextAlignment(.leading)
                //.foregroundColor(.accentColor)
        }
    }
    
    @ViewBuilder private func reportButton() -> some View {
        Button {
            //TODO: ...
            viewModel.alertMessage = .presentedError(message: "Not implemented yet.")
        } label: {
            Text("Report")
                .font(baseSize: 11, weight: .medium)
                .multilineTextAlignment(.leading)
                //.foregroundColor(.accentColor)
        }
    }
    
    @ViewBuilder private func editButton() -> some View {
        Button {
            viewModel.editComment()
        } label: {
            Text("Edit")
                .font(baseSize: 11, weight: .medium)
                .multilineTextAlignment(.leading)
                //.foregroundColor(.accentColor)
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
                //.foregroundColor(.accentColor)
        }
    }
}

struct RantCommentView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 10) {
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
                            backgroundColor: "00cc00",
                            avatarImage: nil
                        ),
                        isUserDPP: 1,
                        attachedImage: nil
                    )
                )
            )
            
            Divider()
            
            RantCommentView(
                viewModel: .init(
                    comment: .init(
                        id: 2,
                        rantID: 1,
                        body: "Comment from me",
                        score: 100,
                        createdTime: Int(Date().addingTimeInterval(60 * -15).timeIntervalSince1970),
                        voteState: .unvotable,
                        links: nil, //TODO: test links
                        userID: 1,
                        username: "Myself and Me",
                        userScore: 12,
                        userAvatar: .init(
                            backgroundColor: "00cc00",
                            avatarImage: nil
                        ),
                        isUserDPP: 0,
                        attachedImage: nil
                    )
                )
            )
        }
    }
}
