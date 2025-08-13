//
//  RantList.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 24.11.22.
//

import SwiftUI
import SwiftDevRant

struct RantList: View {
    let sourceTab: InternalView.Tab
    let rants: [Rant]
    var isLoadingMore = false
    var loadMore: (() -> ())?
    
    var body: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            ForEach(rants, id: \.id) { rant in
                let hidden = UserSettings().ignoredUsers.contains(rant.author.name)
                if !hidden {
                    row(rant: rant)
                        .id(rant.hashValue)
                }
            }
            
            Button {
                loadMore?()
            } label: {
                Text("load more")
                    .foregroundColor(.primaryAccent)
            }
            .buttonStyle(.plain)
            .disabled(isLoadingMore)
            .fillHorizontally(.center)
            .padding()
        }
    }
    
    @MainActor @ViewBuilder func row(rant: Rant) -> some View {
        VStack(spacing: 0) {
            FeedRantView(
                sourceTab: sourceTab,
                viewModel: .init(rant: rant)
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            
            Divider()
        }
    }
}

struct RantList_Previews: PreviewProvider {
    static var previews: some View {
        RantList(sourceTab: .feed, rants: [])
    }
}
