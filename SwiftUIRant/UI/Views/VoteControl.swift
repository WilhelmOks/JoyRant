//
//  VoteControl.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 30.08.22.
//

import SwiftUI
import SwiftDevRant

struct VoteControl: View {
    @Environment(\.isEnabled) private var isEnabled
    
    var isHorizontal = false
    let score: Int
    var isUpvoted: Bool = false
    var isDownvoted: Bool = false
    let upvoteAction: () -> ()
    let downvoteAction: (DownvoteReason?) -> ()
    
    @State private var downvoteReasonOptionsPresented = false
    
    var body: some View {
        content()
            .actionSheet(isPresented: $downvoteReasonOptionsPresented) {
                ActionSheet(
                    title: Text("Downvote reason"),
                    message: Text("Make this automatic in settings"),
                    buttons: [
                        .default(Text("Not for me")) {
                            downvoteAction(.notForMe)
                        },
                        .default(Text("Repost")) {
                            downvoteAction(.repost)
                        },
                        .default(Text("Offensive or spam")) {
                            downvoteAction(.offensiveOrSpam)
                        },
                        .cancel()
                    ]
                )
            }
    }
    
    @ViewBuilder private func content() -> some View {
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
            .foregroundColor(.primaryForeground)
            .padding(4)
            .padding(.bottom, 1)
            .background {
                Circle()
                    .foregroundColor(highlighted ? .primaryAccent : .secondaryBackground)
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
            action: {
                if isDownvoted {
                    downvoteAction(nil)
                } else {
                    if let reason = AppState.shared.automaticDownvoteReason {
                        downvoteAction(reason)
                    } else {
                        downvoteReasonOptionsPresented = true
                    }
                }
            }
        )
    }
    
    @ViewBuilder private func scoreText() -> some View {
        Text("\(score)")
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundColor(isUpvoted || isDownvoted ? .primaryAccent : .primaryForeground)
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
                downvoteAction: { _ in }
            )
            
            VoteControl(
                isHorizontal: true,
                score: 42,
                isUpvoted: true,
                isDownvoted: false,
                upvoteAction: {},
                downvoteAction: { _ in }
            )
            
            VoteControl(
                isHorizontal: true,
                score: 42,
                isUpvoted: false,
                isDownvoted: false,
                upvoteAction: {},
                downvoteAction: { _ in }
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
                    downvoteAction: { _ in }
                )
                
                VoteControl(
                    isHorizontal: false,
                    score: 42,
                    isUpvoted: true,
                    isDownvoted: false,
                    upvoteAction: {},
                    downvoteAction: { _ in }
                )
                
                VoteControl(
                    isHorizontal: false,
                    score: 42,
                    isUpvoted: false,
                    isDownvoted: false,
                    upvoteAction: {},
                    downvoteAction: { _ in }
                )
                .disabled(true)
            }
        }
    }
}
