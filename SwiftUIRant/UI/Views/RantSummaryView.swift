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
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.primaryForeground)
                
                image()
                
                tags()
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
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(.secondaryForeground)
                .padding(.top, 1)
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
