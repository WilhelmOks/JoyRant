//
//  FeedRantView.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 29.08.22.
//

import SwiftUI
import SwiftRant

struct FeedRantView: View {
    @StateObject var viewModel: FeedRantViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
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
                
                Spacer()
                
                Text(TimeFormatter.shared.string(fromSeconds: viewModel.rant.createdTime))
                    .font(baseSize: 11, weight: .medium)
                    .foregroundColor(.secondaryForeground)
            }
            
            Text(viewModel.rant.text)
                .font(baseSize: 15)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .foregroundColor(.primaryForeground)
            
            image()
            
            HStack {
                tags()
                
                Spacer()
                
                commentsCounter()
            }
        }
        .alert($viewModel.alertMessage)
        .background(Color.primaryBackground)
        .onReceive(viewModel.voteController.objectWillChange) {
            viewModel.objectWillChange.send()
        }
        .onReceive(
            broadcastEvent: .shouldUpdateRantInFeed(
                rantId: viewModel.rant.id
            ), perform: { _ in
                viewModel.updateRant()
            }
        )
        .onTapGesture(count: 2) {
            Task {
                await viewModel.voteController.voteByContext()
            }
        }
        .onTapGesture {
            AppState.shared.navigationPath.append(.rantDetails(rantId: viewModel.rant.id))
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
    
    /// Contrary to the original counter, this one will also be visible when there are 0 comments.
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

struct FeedRantView_Previews: PreviewProvider {
    static var previews: some View {
        FeedRantView(viewModel: .init(rant: .mocked()))
            .previewLayout(.sizeThatFits)
            .eachColorScheme()
            .padding()
    }
}
