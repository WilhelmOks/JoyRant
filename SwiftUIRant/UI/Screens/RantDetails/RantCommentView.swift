//
//  RantCommentView.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 21.09.22.
//

import SwiftUI
import SwiftDevRant

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
    
    private struct UpvotersInfoPopoverItem: Identifiable {
        let id: UUID = UUID()
        let upvoters: [String]
    }
    
    @State private var upvotersInfoPopoverItem: UpvotersInfoPopoverItem?
    
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
                postedContent: viewModel.comment.text,
                links: viewModel.comment.linksInText
            )
            
            Text(text)
                .font(baseSize: 16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .foregroundColor(.primaryForeground)
                #if os(iOS)
                .onTapGesture { } //this prevents onLongPressGesture from interrupting the scrolling gesture on iOS 16
                .onLongPressGesture {
                    textSelectionPopoverItem = .init(text: viewModel.comment.text)
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
                    if !viewModel.comment.isFromLoggedInUser {
                        replyButton()
                    }
                    
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
                HStack(spacing: 10) {
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
                        downvoteAction: { reason in
                            Task {
                                await voteController.voteDown(reason: reason)
                            }
                        }
                    )
                    .disabled(comment.voteState == .unvotable)
                    
                    let upvoters = DataStore.shared.upvoters(forComment: comment)
                    
                    if comment.isFromLoggedInUser && !upvoters.isEmpty {
                        Button {
                            upvotersInfoPopoverItem = .init(upvoters: upvoters)
                        } label: {
                            Image(systemName: "info.circle")
                        }
                        .tint(.secondaryForeground)
                        .popover(item: $upvotersInfoPopoverItem) { item in
                            NavigationStack {
                                UpvotersView(upvoters: item.upvoters)
                                    .navigationBarTitleDisplayModeInline()
                            }
                            .presentationDetents([.medium])
                        }
                    }
                }
                
                if isLinkToRant {
                    UserPanel(
                        avatar: comment.author.avatarSmall,
                        name: comment.author.name,
                        score: comment.author.score,
                        isSupporter: comment.isUserSupporter
                    )
                } else {
                    NavigationLink(value: AppState.NavigationDestination.userProfile(userId: comment.author.id)) {
                        UserPanel(
                            avatar: comment.author.avatarSmall,
                            name: comment.author.name,
                            score: comment.author.score,
                            isSupporter: comment.isUserSupporter
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 6) {
                CreationTimeView(
                    createdTime: comment.created,
                    isEdited: comment.isEdited
                )
            }
        }

    }
    
    @ViewBuilder private func image() -> some View {
        if let image = viewModel.comment.image {
            PostedImage(image: image, opensSheet: true)
        }
        
        let imageURLs = viewModel.comment.linksInText.imageURLs()
        
        ForEach(imageURLs, id: \.self) { url in
            URLImage(url: url)
        }
    }
        
    @ViewBuilder private func replyButton() -> some View {
        Button {
            DataStore.shared.writePostContent.append("@\(viewModel.comment.author.name) ")
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
                        id: 3,
                        rantId: 1,
                        voteState: .unvoted,
                        score: 56,
                        author: .init(
                            id: 1,
                            name: "Saul Goodman",
                            score: 43,
                            devRantSupporter: true,
                            avatarSmall: .init(colorHex: "00cc00", imageUrlPath: nil),
                            avatarLarge: .init(colorHex: "00cc00", imageUrlPath: nil)
                        ),
                        created: Date(),
                        isEdited: false,
                        text: "Lorem Ipsum",
                        linksInText: [],
                        image: nil
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
                        rantId: 1,
                        voteState: .unvotable,
                        score: 100,
                        author: .init(
                            id: 1,
                            name: "Myself and Me",
                            score: 12,
                            devRantSupporter: true,
                            avatarSmall: .init(colorHex: "00cc00", imageUrlPath: nil),
                            avatarLarge: .init(colorHex: "00cc00", imageUrlPath: nil)
                        ),
                        created: Date(),
                        isEdited: false,
                        text: "Comment from me",
                        linksInText: [],
                        image: nil
                    )
                ),
                onReply: {},
                onEdit: {},
                onDelete: {}
            )
        }
    }
}
