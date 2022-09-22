//
//  FeedView.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 29.08.22.
//

import SwiftUI
import SwiftRant

struct FeedView: View {
    @ObservedObject private var dataStore = DataStore.shared
    @StateObject private var viewModel = FeedViewModel()
    
    var body: some View {
        content()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        DispatchQueue.main.async {
                            Networking.shared.logOut()
                        }
                    } label: {
                        Text("Log out")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            await viewModel.reload()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(viewModel.isLoading || viewModel.isLoadingMore)
                }
            }
            .navigationTitle("devRant")
            .navigationBarTitleDisplayMode(.inline)
            .alert($viewModel.alertMessage)
            .navigationDestination(for: AppState.NavigationDestination.self) { destination in
                switch destination {
                case .rantDetails(let rantId):
                    RantDetailsView(
                        viewModel: .init(
                            rantId: rantId
                        )
                    )
                }
            }
            /*.onReceive(notification: .init(rawValue: "ShouldUpdateFeed")) { _ in
                dataStore.objectWillChange.send()
            }*/
    }
    
    @ViewBuilder func content() -> some View {
        ZStack {
            if dataStore.isFeedLoaded {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(dataStore.rantsInFeed, id: \.id) { rant in
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
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            FeedView()
        }
    }
}
