//
//  FeedView.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 29.08.22.
//

import SwiftUI
import SwiftRant

struct FeedView: View {
    var navigationBar = true
    
    @ObservedObject private var dataStore = DataStore.shared
    @StateObject private var viewModel = FeedViewModel()
    
    var body: some View {
        content()
            .if(navigationBar) {
                $0
                .toolbar {
                    sortPicker()
                        .disabled(viewModel.isLoading || viewModel.isLoadingMore || viewModel.isReloading)
                }
                .navigationTitle("Feed")
            }
            .background(Color.primaryBackground)
            .alert($viewModel.alertMessage)
            .navigationDestination(for: AppState.NavigationDestination.self) { destination in
                switch destination {
                case .rantDetails(let rantId):
                    RantDetailsView(
                        sourceTab: .feed,
                        viewModel: .init(
                            rantId: rantId
                        )
                    )
                }
            }
    }
    
    @ViewBuilder func content() -> some View {
        ZStack {
            if dataStore.isFeedLoaded {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(dataStore.rantsInFeed, id: \.uuid) { rant in
                            row(rant: rant)
                        }
                        
                        Button {
                            Task {
                                await viewModel.loadMore()
                            }
                        } label: {
                            Text("load more")
                                .foregroundColor(.accentColor)
                        }
                        .buttonStyle(.plain)
                        .disabled(viewModel.isLoadingMore)
                        .fillHorizontally(.center)
                        .padding()
                    }
                }
                .refreshable {
                    await viewModel.reload()
                }
            } else {
                ProgressView()
                    .opacity(viewModel.isLoading ? 1 : 0)
            }
        }
    }
    
    @ViewBuilder func row(rant: RantInFeed) -> some View {
        VStack(spacing: 0) {
            FeedRantView(viewModel: .init(rant: rant))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
            
            Divider()
        }
    }
        
    @ViewBuilder func sortPicker() -> some View {
        Picker(selection: $viewModel.sort, label: Text(viewModel.sort.name)) {
            ForEach(FeedViewModel.Sort.allCases) { item in
                Text(item.name).tag(item)
            }
        }
        .pickerStyle(.menu)
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            FeedView()
        }
    }
}
