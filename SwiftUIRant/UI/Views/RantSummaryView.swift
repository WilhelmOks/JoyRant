//
//  RantSummaryView.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 29.08.22.
//

import SwiftUI
import SwiftRant

struct RantSummaryView: View {
    @StateObject var viewModel: RantSummaryViewModel
    //@ObservedObject private var dataStore = DataStore.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VoteControl(
                isHorizontal: true,
                score: viewModel.voteScore,
                isUpvoted: viewModel.showAsUpvoted,
                isDownvoted: viewModel.showAsDownvoted,
                upvoteAction: {
                    Task {
                        await viewModel.voteUp()
                    }
                },
                downvoteAction: {
                    Task {
                        await viewModel.voteDown()
                    }
                }
            )
            .disabled(viewModel.rant.voteState == .unvotable)
            
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
    
    /// Contrary to the original counter, this one will also show 0 comments.
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

struct RantSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        RantSummaryView(viewModel: .init(rant: .mocked()))
            .previewLayout(.sizeThatFits)
            .eachColorScheme()
            .padding()
    }
}
