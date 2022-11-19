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
    
    enum PresentedSheet: Identifiable {
        case postRant
        
        var id: String {
            switch self {
            case .postRant:
                return "post_rant"
            }
        }
    }
    
    @State private var presentedSheet: PresentedSheet?
    
    var body: some View {
        content()
            .if(navigationBar) {
                $0
                .toolbar {
                    sortPicker()
                        .disabled(viewModel.isLoading || viewModel.isLoadingMore || viewModel.isReloading)
                    
                    #if os(macOS)
                    LoadingButton(isLoading: viewModel.isReloading || viewModel.isLoading || viewModel.isLoadingMore) {
                        Task {
                            await viewModel.reload()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    #endif
                }
                .navigationTitle("Feed")
            }
            .background(Color.primaryBackground)
            .alert($viewModel.alertMessage)
            .sheet(item: $presentedSheet) { item in
                switch item {
                case .postRant:
                    WritePostView(
                        viewModel: .init(
                            kind: .postRant,
                            onSubmitted: {}
                        )
                    )
                }
            }
            .navigationDestination(for: AppState.NavigationDestination.self) { destination in
                switch destination {
                case .rantDetails(let rantId):
                    RantDetailsView(
                        sourceTab: .feed,
                        viewModel: .init(
                            rantId: rantId
                        )
                    )
                case .userProfile(let userId):
                    ProfileView(viewModel: .init(userId: userId))
                }
            }
            .onReceive(broadcastEvent: .didReselectMainTab(.feed)) { _ in
                if AppState.shared.navigationPath.isEmpty {
                    DispatchQueue.main.async {
                        BroadcastEvent.shouldScrollFeedToTop.send()
                    }
                    Task {
                        await viewModel.reload()
                    }
                }
            }
    }
    
    @ViewBuilder func content() -> some View {
        ZStack {
            if dataStore.isFeedLoaded {
                ZStack {
                    ScrollViewReader { scrollProxy in
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 0) {
                                ForEach(dataStore.rantsInFeed, id: \.uuid) { rant in
                                    row(rant: rant)
                                        .id(rant.uuid)
                                }
                                
                                Button {
                                    Task {
                                        await viewModel.loadMore()
                                    }
                                } label: {
                                    Text("load more")
                                        .foregroundColor(.primaryAccent)
                                }
                                .buttonStyle(.plain)
                                .disabled(viewModel.isLoadingMore)
                                .fillHorizontally(.center)
                                .padding()
                            }
                        }
                        .onReceive(broadcastEvent: .shouldScrollFeedToTop) { _ in
                            withAnimation {
                                scrollProxy.scrollTo(dataStore.rantsInFeed.first?.uuid, anchor: .top)
                            }
                        }
                    }
                    .refreshable {
                        await viewModel.reload()
                    }
                    
                    newRantButton()
                    .fill(.bottomTrailing)
                    .padding(10)
                }
            } else {
                ProgressView()
                    .opacity(viewModel.isLoading ? 1 : 0)
            }
        }
    }
    
    @ViewBuilder private func newRantButton() -> some View {
        Button {
            presentedSheet = .postRant
        } label: {
            Label {
                Text("Rant")
            } icon: {
                Image(systemName: "plus")
            }
            .font(baseSize: 13, weightDelta: 1)
        }
        .buttonStyle(.borderedProminent)
    }
    
    @ViewBuilder func row(rant: RantInFeed) -> some View {
        VStack(spacing: 0) {
            FeedRantView(viewModel: .init(rant: rant))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
            
            Divider()
        }
    }
    
    @State private var sortPickerId = UUID()
        
    @ViewBuilder func sortPicker() -> some View {
        Picker(selection: $viewModel.sort, label: Text(viewModel.sort.name)) {
            ForEach(FeedViewModel.Sort.allCases) { item in
                Text(item.name).tag(item)
            }
        }
        .pickerStyle(.menu)
        .id(sortPickerId)
        .onChange(of: AppState.shared.customAccentColor) { newValue in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                sortPickerId = UUID()
            }
        }
        .onChange(of: dataStore.rantsInFeed) { newValue in
            sortPickerId = UUID()
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
