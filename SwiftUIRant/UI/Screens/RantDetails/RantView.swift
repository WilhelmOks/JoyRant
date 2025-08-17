//
//  RantView.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 21.09.22.
//

import SwiftUI
import SwiftDevRant

struct RantView: View {
    @StateObject var viewModel: RantViewModel
    let onEdit: () -> ()
    let onDelete: () -> ()
    
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
            if viewModel.rant.isFromLoggedInUser {
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
                            title: Text("Do you want to delete this rant?"),
                            primaryButton: Alert.Button.cancel(Text("Cancel")),
                            secondaryButton: .destructive(Text("Delete rant"), action: { onDelete() })
                        )
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
            
            let text = AttributedString.from(
                postedContent: viewModel.rant.text,
                links: viewModel.rant.linksInText
            )
            
            Text(text)
                .font(baseSize: 16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .foregroundColor(.primaryForeground)
                #if os(iOS)
                .onTapGesture { } //this prevents onLongPressGesture from interrupting the scrolling gesture on iOS 16
                .onLongPressGesture {
                    textSelectionPopoverItem = .init(text: viewModel.rant.text)
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
            
            HStack(alignment: .bottom, spacing: 10) {
                tags()
                
                Spacer()
                
                if viewModel.rant.isFromLoggedInUser {
                    deleteButton()
                    editButton()
                    commentsCounter()
                } else {
                    //reportButton()
                    commentsCounter()
                }
            }
        }
    }
    
    @ViewBuilder private func topArea(rant: Rant, voteController: VoteController) -> some View {
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
                    .disabled(rant.voteState == .unvotable)
                    
                    let upvoters = DataStore.shared.upvoters(forRant: rant)
                    
                    if rant.isFromLoggedInUser && !upvoters.isEmpty {
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
                
                NavigationLink(value: AppState.NavigationDestination.userProfile(userId: rant.author.id)) {
                    UserPanel(
                        avatar: rant.author.avatarSmall,
                        name: rant.author.name,
                        score: rant.author.score,
                        isSupporter: rant.isUserSupporter
                    )
                }
                .buttonStyle(.plain)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 6) {
                CreationTimeView(
                    createdTime: rant.created,
                    isEdited: rant.isEdited
                )
                
                favoriteButton()
            }
        }
    }
    
    @ViewBuilder private func image() -> some View {
        if let image = viewModel.rant.image {
            PostedImage(image: image, opensSheet: true)
        }
    }
    
    @ViewBuilder private func tags() -> some View {
        let tags = viewModel.rant.tags.joined(separator: ", ")
        
        Text(tags)
            .font(baseSize: 12, weight: .medium)
            .multilineTextAlignment(.leading)
            .foregroundColor(.secondaryForeground)
    }
    
    @ViewBuilder private func commentsCounter() -> some View {
        HStack(spacing: 3) {
            Image(systemName: "bubble.right")
                .font(baseSize: 12)
            
            Text("\(viewModel.rant.numberOfComments)")
                .font(baseSize: 12, weight: .medium)
        }
        .foregroundColor(.secondaryForeground)
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
    
    @ViewBuilder private func favoriteButton() -> some View {
        let isFavorite = viewModel.rant.isFavorite
        
        Button {
            Task {
                if isFavorite {
                    await viewModel.unfavorite()
                } else {
                    await viewModel.favorite()
                }
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .font(baseSize: 12)
                
                Text(isFavorite ? "Unfavorite" : "Favorite")
                    .font(baseSize: 12, weight: .medium)
                    .multilineTextAlignment(.leading)
            }
        }
        .disabled(viewModel.isLoading)
    }
    
    private func edit() {
        guard viewModel.rant.canEdit else {
            viewModel.alertMessage = .presentedMessage(SwiftUIRantError.timeWindowForEditMissed.message)
            return
        }
        DataStore.shared.writePostContent = viewModel.rant.withResolvedLinks
        onEdit()
    }
    
    private func delete() {
        isDeleteConfirmationAlertPresented = true
    }
}

struct RantView_Previews: PreviewProvider {
    static var previews: some View {
        RantView(
            viewModel: .init(
                rant: .init(
                    id: 1,
                    linkToRant: nil,
                    voteState: .unvoted,
                    score: 83,
                    author: .init(
                        id: 2,
                        name: "Spongeblob",
                        score: 666,
                        devRantSupporter: false,
                        avatarSmall: .init(colorHex: "66cc66", imageUrlPath: nil),
                        avatarLarge: .init(colorHex: "66cc66", imageUrlPath: nil)
                    ),
                    created: Date().addingTimeInterval(-15),
                    isEdited: true,
                    isFavorite: false,
                    text: "Lorem ipsum dolor sit a rant",
                    linksInText: [],
                    image: nil,
                    numberOfComments: 2,
                    tags: ["rant", "js suxx"],
                    weekly: nil,
                    collaboration: nil
                )
            ),
            onEdit: {},
            onDelete: {}
        )
    }
}
