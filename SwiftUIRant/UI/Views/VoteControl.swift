//
//  VoteControl.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 30.08.22.
//

import SwiftUI

struct VoteControl: View {
    let score: Int
    var isUpvoted: Bool = false
    var isDownvoted: Bool = false
    let upvoteAction: () -> ()
    let downvoteAction: () -> ()
    
    var body: some View {
        VStack(spacing: 2) {
            button(
                text: "++",
                hiddenText: "--",
                highlighted: isUpvoted,
                action: upvoteAction
            )
            
            Text("\(score)")
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(isUpvoted || isDownvoted ? .accentColor : .secondary)
            
            button(
                text: "--",
                hiddenText: "++",
                highlighted: isDownvoted,
                action: downvoteAction
            )
        }
    }
    
    @ViewBuilder private func button(text: String, hiddenText: String, highlighted: Bool, action: @escaping () -> ()) -> some View {
        Button {
            action()
        } label: {
            ZStack {
                Text(text)
                Text(hiddenText)
                    .hidden()
                    .accessibilityHidden(true)
            }
            .font(.caption)
            .fontWeight(.bold)
            .foregroundColor(.white) //TODO: use a more dynamic color
            .padding(3)
            .padding(.bottom, 1)
            .background {
                Circle()
                    .foregroundColor(highlighted ? .accentColor : .secondary)
            }
        }
    }
}

struct VoteControl_Previews: PreviewProvider {
    static var previews: some View {
        VoteControl(
            score: 42,
            isUpvoted: true,
            isDownvoted: false,
            upvoteAction: {},
            downvoteAction: {}
        )
    }
}
