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
    let onEdit: () -> ()
    let onDelete: () -> ()
    
    @State private var isDeleteConfirmationAlertPresented = false
    
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
                links: viewModel.rant.links
            )
            
            Text(text)
                .font(baseSize: 16)
                .textSelection(.enabled)
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
                    //reportButton()
                    commentsCounter()
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
                
                NavigationLink(value: AppState.NavigationDestination.userProfile(userId: rant.userID)) {
                    UserPanel(
                        avatar: rant.userAvatar,
                        name: rant.username,
                        score: rant.userScore,
                        isSupporter: rant.isUserSupporter
                    )
                }
                .buttonStyle(.plain)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 6) {
                CreationTimeView(
                    createdTime: rant.createdTime,
                    isEdited: rant.isEdited
                )
                
                favoriteButton()
            }
        }
    }
    
    @ViewBuilder private func image() -> some View {
        if let image = viewModel.rant.attachedImage {
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
            
            Text("\(viewModel.rant.commentCount)")
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
        let isFavorite = viewModel.rant.isFavorite == 1
        
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
                    isFavorite: 0,
                    link: nil,
                    links: nil,
                    collabTypeLong: nil, //TODO: test
                    collabDescription: nil, //TODO: test
                    collabTechStack: nil, //TODO: test
                    collabTeamSize: nil, //TODO: test
                    collabURL: nil, //TODO: test
                    userID: 2,
                    username: "Spongeblob",
                    userScore: 666,
                    userAvatar: .init(
                        backgroundColor: "66cc66",
                        avatarImage: nil
                    ),
                    userAvatarLarge: .init(
                        backgroundColor: "66cc66",
                        avatarImage: nil
                    ),
                    isUserDPP: nil
                )
            ),
            onEdit: {},
            onDelete: {}
        )
    }
}
