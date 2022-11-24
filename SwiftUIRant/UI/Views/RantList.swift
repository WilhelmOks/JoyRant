//
//  RantList.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 24.11.22.
//

import SwiftUI
import SwiftRant

struct RantList: View {
    let rants: [RantInFeed]
    var isLoadingMore = false
    var loadMore: (() -> ())?
    
    var body: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            ForEach(rants, id: \.uuid) { rant in
                row(rant: rant)
                    .id(rant.uuid)
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
    
    @MainActor @ViewBuilder func row(rant: RantInFeed) -> some View {
        VStack(spacing: 0) {
            FeedRantView(viewModel: .init(rant: rant))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
            
            Divider()
        }
    }
}

struct RantList_Previews: PreviewProvider {
    static var previews: some View {
        RantList(rants: [])
    }
}
