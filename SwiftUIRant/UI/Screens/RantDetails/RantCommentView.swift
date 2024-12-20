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
    var isLinkToRant = false
    var onReply: (() -> ())?
    var onEdit: (() -> ())?
    var onDelete: (() -> ())?
    
    @State private var isDeleteConfirmationAlertPresented = false
    
    private struct TextSelectionPopoverItem: Identifiable {
        let id: UUID = UUID()
        let text: String
    }
    
    @State private var textSelectionPopoverItem: TextSelectionPopoverItem?
    
    var body: some View {
        content()
        .padding(.top, 10)
        .padding(.horizontal, 10)
        .background(Color.primaryBackground)
        .onReceive(viewModel.voteController.objectWillChange) {
            viewModel.objectWillChange.send()
        }
        .onTapGesture(count: 2) {
            if viewModel.comment.isFromLoggedInUser {
                edit()
            } else {
                Task {
                    await viewModel.voteController.voteByContext()
                }
            }
        }
        .background {
            ZStack {
                ZStack {}
                    .alert($viewModel.alertMessage)
                
                ZStack {}
                    .alert(isPresented: $isDeleteConfirmationAlertPresented) {
                        Alert(
                            title: Text("Do you want to delete this comment?"),
                            primaryButton: Alert.Button.cancel(Text("Cancel")),
                            secondaryButton: .destructive(Text("Delete comment"), action: { onDelete?() })
                        )
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
            
            let text = AttributedString.from(
                postedContent: viewModel.comment.body,
                links: viewModel.comment.links
            )
            
            Text(text)
                .font(baseSize: 16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .foregroundColor(.primaryForeground)
                #if os(iOS)
                .onTapGesture { } //this prevents onLongPressGesture from interrupting the scrolling gesture on iOS 16
                .onLongPressGesture {
                    textSelectionPopoverItem = .init(text: viewModel.comment.body)
                }
                .popover(item: $textSelectionPopoverItem) { item in
                    TextEditor(text: .constant(item.text))
                        .padding(.top, 8)
                        .padding(.horizontal, 4)
                        .ignoresSafeArea(edges: .bottom)
                        .introspect(.textEditor, on: .iOS(.v16, .v17, .v18)) { editor in
                            editor.isEditable = false
                        }
                        .presentationDetents([.medium, .large])
                }
                #else
                .textSelection(.enabled)
                #endif
            
            image()
            
            if !isLinkToRant {
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
                
                if isLinkToRant {
                    UserPanel(
                        avatar: comment.userAvatar,
                        name: comment.username,
                        score: comment.userScore,
                        isSupporter: comment.isUserSupporter
                    )
                } else {
                    NavigationLink(value: AppState.NavigationDestination.userProfile(userId: comment.userID)) {
                        UserPanel(
                            avatar: comment.userAvatar,
                            name: comment.username,
                            score: comment.userScore,
                            isSupporter: comment.isUserSupporter
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 6) {
                CreationTimeView(
                    createdTime: comment.createdTime,
                    isEdited: comment.isEdited
                )
            }
        }

    }
    
    @ViewBuilder private func image() -> some View {
        if let image = viewModel.comment.attachedImage {
            PostedImage(image: image, opensSheet: true)
        }
    }
        
    @ViewBuilder private func replyButton() -> some View {
        Button {
            DataStore.shared.writePostContent.append("@\(viewModel.comment.username) ")
            onReply?()
        } label: {
            Text("Reply")
                .font(baseSize: 12, weight: .medium)
                .multilineTextAlignment(.leading)
        }
    }
    
    @ViewBuilder private func reportButton() -> some View {
        Button {
            //TODO: ...
            viewModel.alertMessage = .presentedError(message: "Not implemented yet.")
        } label: {
            Text("Report")
                .font(baseSize: 12, weight: .medium)
                .multilineTextAlignment(.leading)
        }
    }
    
    @ViewBuilder private func editButton() -> some View {
        Button {
            edit()
        } label: {
            Text("Edit")
                .font(baseSize: 12, weight: .medium)
                .multilineTextAlignment(.leading)
        }
    }
    
    @ViewBuilder private func deleteButton() -> some View {
        Button {
            delete()
        } label: {
            Text("Delete")
                .font(baseSize: 12, weight: .medium)
                .multilineTextAlignment(.leading)
        }
    }
    
    private func edit() {
        guard viewModel.comment.canEdit else {
            viewModel.alertMessage = .presentedMessage(SwiftUIRantError.timeWindowForEditMissed.message)
            return
        }
        DataStore.shared.writePostContent = viewModel.comment.withResolvedLinks
        onEdit?()
    }
    
    private func delete() {
        isDeleteConfirmationAlertPresented = true
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
                        links: nil,
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
                ),
                onReply: {},
                onEdit: {},
                onDelete: {}
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
                        links: nil,
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
                ),
                onReply: {},
                onEdit: {},
                onDelete: {}
            )
        }
    }
}
