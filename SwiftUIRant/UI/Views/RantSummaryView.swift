//
//  RantSummaryView.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 29.08.22.
//

import SwiftUI
import SwiftRant

struct RantSummaryView: View {
    let rant: RantInFeed?
    
    var body: some View {
        if let rant = rant {
            VStack(alignment: .leading, spacing: 8) {
                VoteControl(
                    isHorizontal: true,
                    score: rant.score,
                    isUpvoted: rant.voteState == .upvoted,
                    isDownvoted: rant.voteState == .downvoted,
                    upvoteAction: {},
                    downvoteAction: {}
                )
                .disabled(rant.voteState == .unvotable)
                
                Text(rant.text)
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
        }
    }
    
    @ViewBuilder private func image() -> some View {
        if let image = rant?.attachedImage {
            PostedImage(image: image)
        }
    }
    
    @ViewBuilder private func tags() -> some View {
        if let rant = rant {
            let tags = rant.tags.joined(separator: ", ")
            
            Text(tags)
                .font(baseSize: 11, weight: .medium)
                .multilineTextAlignment(.leading)
                .foregroundColor(.secondaryForeground)
        }
    }
    
    /// Contrary to the original counter, this one will also show 0 comments.
    @ViewBuilder private func commentsCounter() -> some View {
        if let rant = rant {
            HStack(spacing: 3) {
                Image(systemName: "bubble.right")
                    .font(baseSize: 11)
                
                Text("\(rant.commentCount)")
                    .font(baseSize: 11, weight: .medium)
            }
            .foregroundColor(.secondaryForeground)
        }
    }
}

struct RantSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        RantSummaryView(rant: .mocked())
            .previewLayout(.sizeThatFits)
            .eachColorScheme()
            .padding()
    }
}
