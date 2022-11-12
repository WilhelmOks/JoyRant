//
//  RantDetailsView.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 17.09.22.
//

import SwiftUI
import SwiftRant

struct RantDetailsView: View {
    @Environment(\.presentationMode) private var presentationMode

    let sourceTab: InternalView.Tab
    @StateObject var viewModel: RantDetailsViewModel
    
    enum PresentedSheet: Identifiable {
        case postComment(rantId: Rant.ID)
        case editComment(comment: Comment)
        
        var id: String {
            switch self {
            case .postComment(rantId: let id):
                return "post_comment_\(String(id))"
            case .editComment(comment: let comment):
                return "edit_comment_\(String(comment.id))"
            }
        }
    }
    
    @State private var presentedSheet: PresentedSheet?
        
    var body: some View {
        content()
            .background(Color.primaryBackground)
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    toolbarReloadButton()
                }
            }
            .navigationTitle("Rant")
            .alert($viewModel.alertMessage)
            .sheet(item: $presentedSheet) { item in
                switch item {
                case .postComment(rantId: let rantId):
                    WritePostView(
                        viewModel: .init(
                            kind: .postComment(rantId: rantId),
                            mentionSuggestions: viewModel.commentMentionSuggestions(),
                            onSubmitted: {
                                Task {
                                    await viewModel.reload()
                                    DispatchQueue.main.async {
                                        viewModel.scrollToCommentWithId = viewModel.comments.last?.id
                                        BroadcastEvent.shouldScrollToComment.send()
                                    }
                                }
                            }
                        )
                    )
                case .editComment(comment: let comment):
                    WritePostView(
                        viewModel: .init(
                            kind: .editComment(comment: comment),
                            mentionSuggestions: viewModel.commentMentionSuggestions(),
                            onSubmitted: {
                                Task {
                                    await viewModel.reload()
                                }
                            }
                        )
                    )
                }
            }
            .onReceive(broadcastEvent: .didReselectMainTab(.feed)) { _ in
                if sourceTab == .feed {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .onReceive(broadcastEvent: .didReselectMainTab(.notifications)) { _ in
                if sourceTab == .notifications {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .onReceive(viewModel.dismiss) { _ in
                presentationMode.wrappedValue.dismiss()
            }
            .onOpenURL{ url in
                if (url.scheme == "joyrant" && url.host == "rant") {
                    guard let rantId = url.pathComponents.last.flatMap(Int.init) else {
                        dlog("Rant ID could not be parsed: \(url)")
                        return
                    }
                    
                    switch sourceTab {
                    case .feed:
                        AppState.shared.navigationPath.append(.rantDetails(rantId: rantId))
                    case .notifications:
                        let destination = AppState.NavigationDestination.rantDetails(rantId: rantId)
                        AppState.shared.notificationsNavigationPath.append(destination)
                    case .settings:
                        break
                    }
                }
            }
    }
    
    @ViewBuilder private func content() -> some View {
        if let rant = viewModel.rant, !viewModel.isLoading {
            ZStack {
                ScrollViewReader { scrollProxy in
                    ScrollView {
                        LazyVStack { // caution: Lazy might cause problems with scrollTo()
                            RantView(
                                viewModel: .init(
                                    rant: rant
                                ),
                                onDelete: {
                                    Task {
                                        await viewModel.deleteRant(rant: rant)
                                    }
                                }
                            )
                            .id(rant.uuid)
                            
                            ForEach(viewModel.comments, id: \.id) { comment in
                                VStack(spacing: 0) {
                                    Divider()
                                    
                                    RantCommentView(
                                        viewModel: .init(comment: comment),
                                        onReply: {
                                            presentedSheet = .postComment(rantId: viewModel.rantId)
                                        },
                                        onEdit: {
                                            presentedSheet = .editComment(comment: comment)
                                        },
                                        onDelete: {
                                            Task {
                                                await viewModel.deleteComment(comment: comment)
                                            }
                                        }
                                    )
                                    //.id(comment.uuid) //TODO: make uuid public
                                    .id("\(rant.uuid)_\(comment.id)")
                                }
                                .id("comment_\(comment.id)")
                            }
                        }
                        .padding(.bottom, 10)
                        .padding(.bottom, 40) //TODO: measure comment button size and set it here
                    }
                    .onReceive(broadcastEvent: .shouldScrollToComment) { _ in
                        if let commentId = viewModel.scrollToCommentWithId {
                            withAnimation {
                                scrollProxy.scrollTo("comment_\(commentId)", anchor: .top)
                            }
                        }
                    }
                }
                
                commentButton()
                .fill(.bottomTrailing)
                .padding(10)
            }
        } else {
            ProgressView()
        }
    }
    
    @ViewBuilder private func commentButton() -> some View {
        Button {
            presentedSheet = .postComment(rantId: viewModel.rantId)
        } label: {
            Label {
                Text("Comment")
            } icon: {
                Image(systemName: "bubble.right")
            }
            .font(baseSize: 13, weightDelta: 1)
        }
        .buttonStyle(.borderedProminent)
    }
    
    @ViewBuilder private func toolbarReloadButton() -> some View {
        ZStack {
            ProgressView()
                .opacity(viewModel.isReloading ? 1 : 0)
                
            Button {
                Task {
                    await viewModel.reload()
                }
            } label: {
                Image(systemName: "arrow.clockwise")
                    .frame(width: 26, height: 26)
            }
            .disabled(viewModel.isLoading)
            .opacity(!viewModel.isReloading ? 1 : 0)
        }
    }
    
    @ViewBuilder private func toolbarMoreButton() -> some View {
        Button {
            //TODO: ...
            viewModel.alertMessage = .presentedError(message: "Not implemented yet.")
        } label: {
            Image(systemName: "ellipsis")
                .frame(width: 26, height: 26)
        }
        .disabled(viewModel.isLoading)
    }
}

struct RantDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        RantDetailsView(
            sourceTab: .feed,
            viewModel: .init(
                rantId: 1
            )
        )
    }
}
