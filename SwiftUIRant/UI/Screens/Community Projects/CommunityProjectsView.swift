//
//  CommunityProjectsView.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 07.04.23.
//

import SwiftUI

struct CommunityProjectsView: View {
    @StateObject private var viewModel: CommunityProjectsViewModel = .init()
    
    var body: some View {
        if viewModel.isLoading {
            ProgressView()
        } else {
            content()
                .alert($viewModel.alertMessage)
                .navigationTitle(Text("Community Projects"))
                .searchable(text: $viewModel.searchText)
        }
    }
    
    @ViewBuilder private func content() -> some View {
        ScrollView {
            LazyVStack {
                ForEach(viewModel.items, id: \.self) { item in
                    VStack(spacing: 0) {
                        CommunityProjectRowView(communityProject: item)
                            .padding(.horizontal, 10)
                            .padding(.bottom, 10)
                        Divider()
                    }
                }
            }
            .padding(.vertical, 10)
        }
    }
}

struct CommunityProjectsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CommunityProjectsView()
        }
    }
}
