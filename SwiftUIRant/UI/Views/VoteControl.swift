//
//  VoteControl.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 30.08.22.
//

import SwiftUI

struct VoteControl: View {
    @Environment(\.isEnabled) private var isEnabled
    
    var isHorizontal = false
    let score: Int
    var isUpvoted: Bool = false
    var isDownvoted: Bool = false
    let upvoteAction: () -> ()
    let downvoteAction: () -> ()
    
    var body: some View {
        if isHorizontal {
            HStack(spacing: 4) {
                downvoteButton()
                
                scoreText()
                
                upvoteButton()
            }
        } else {
            VStack(spacing: 2) {
                upvoteButton()
                
                scoreText()
                
                downvoteButton()
            }
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
            .foregroundColor(.primaryBackground)
            .padding(3)
            .padding(.bottom, 1)
            .background {
                Circle()
                    .foregroundColor(highlighted ? .accentColor : .secondaryForeground)
            }
            .opacity(isEnabled ? 1 : 0.6)
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder private func upvoteButton() -> some View {
        button(
            text: "++",
            hiddenText: "--",
            highlighted: isUpvoted,
            action: upvoteAction
        )
    }
    
    @ViewBuilder private func downvoteButton() -> some View {
        button(
            text: "--",
            hiddenText: "++",
            highlighted: isDownvoted,
            action: downvoteAction
        )
    }
    
    @ViewBuilder private func scoreText() -> some View {
        Text("\(score)")
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundColor(isUpvoted || isDownvoted ? .accentColor : .secondaryForeground)
    }
}

struct VoteControl_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            VoteControl(
                isHorizontal: true,
                score: 42,
                isUpvoted: false,
                isDownvoted: false,
                upvoteAction: {},
                downvoteAction: {}
            )
            
            VoteControl(
                isHorizontal: true,
                score: 42,
                isUpvoted: true,
                isDownvoted: false,
                upvoteAction: {},
                downvoteAction: {}
            )
            
            VoteControl(
                isHorizontal: true,
                score: 42,
                isUpvoted: false,
                isDownvoted: false,
                upvoteAction: {},
                downvoteAction: {}
            )
            .disabled(true)
            .padding(.bottom, 30)
            
            HStack(spacing: 16) {
                VoteControl(
                    isHorizontal: false,
                    score: 42,
                    isUpvoted: false,
                    isDownvoted: false,
                    upvoteAction: {},
                    downvoteAction: {}
                )
                
                VoteControl(
                    isHorizontal: false,
                    score: 42,
                    isUpvoted: true,
                    isDownvoted: false,
                    upvoteAction: {},
                    downvoteAction: {}
                )
                
                VoteControl(
                    isHorizontal: false,
                    score: 42,
                    isUpvoted: false,
                    isDownvoted: false,
                    upvoteAction: {},
                    downvoteAction: {}
                )
                .disabled(true)
            }
        }
    }
}
