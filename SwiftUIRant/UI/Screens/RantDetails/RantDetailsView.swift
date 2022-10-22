//
//  RantDetailsView.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 17.09.22.
//

import SwiftUI
import SwiftRant

struct RantDetailsView: View {
    @StateObject var viewModel: RantDetailsViewModel
    
    //@State private var presentedWriteCommentView = false
    
    enum PresentedSheet: Identifiable {
        case postComment(rantId: Rant.ID)
        case editComment(commentId: Comment.ID)
        
        var id: String {
            switch self {
            case .postComment(rantId: let id):
                return "post_comment_\(String(id))"
            case .editComment(commentId: let id):
                return "edit_comment_\(String(id))"
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
                
                /*ToolbarItem(placement: .automatic) {
                    toolbarMoreButton()
                }*/
            }
            .navigationTitle("Rant")
            .alert($viewModel.alertMessage)
            .sheet(item: $presentedSheet) { item in
                switch item {
                case .postComment(rantId: let rantId):
                    WriteCommentView(
                        viewModel: .init(
                            kind: .post(rantId: rantId),
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
                case .editComment(commentId: let commentId):
                    WriteCommentView(
                        viewModel: .init(
                            kind: .edit(commentId: commentId),
                            onSubmitted: {
                                Task {
                                    await viewModel.reload()
                                }
                            }
                        )
                    )
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
                                )
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
                                            presentedSheet = .editComment(commentId: comment.id)
                                        }
                                    )
                                    //.id(comment.uuid) //TODO: make uuid public
                                    .id("\(rant.uuid)_\(comment.id)")
                                }
                                .id("comment_\(comment.id)")
                            }
                        }
                        .padding(.bottom, 10)
                        .padding(.bottom, 34) //TODO: measure comment button size and set it here
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
            .font(baseSize: 12, weightDelta: 1)
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
            viewModel: .init(
                rantId: 1
            )
        )
    }
}
