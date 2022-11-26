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
                case .rantDetails(rantId: let rantId, scrollToCommentWithId: let scrollToCommentWithId):
                    RantDetailsView(
                        sourceTab: .feed,
                        viewModel: .init(
                            rantId: rantId,
                            scrollToCommentWithId: scrollToCommentWithId
                        )
                    )
                case .userProfile(userId: let userId):
                    ProfileView(
                        sourceTab: .feed,
                        viewModel: .init(
                            userId: userId
                        )
                    )
                }
            }
            .onReceive(broadcastEvent: .didReselectMainTab(.feed)) { _ in
                if AppState.shared.feedNavigationPath.isEmpty {
                    DispatchQueue.main.async {
                        BroadcastEvent.shouldScrollFeedToTop.send()
                    }
                    Task {
                        await viewModel.reload()
                    }
                }
            }
            .onReceive { event in
                switch event {
                case .shouldUpdateRantInLists(let rant): return rant
                default: return nil
                }
            } perform: { rant in
                DataStore.shared.update(rantInFeed: rant)
            }
    }
    
    @ViewBuilder func content() -> some View {
        ZStack {
            if dataStore.isFeedLoaded {
                ZStack {
                    ScrollViewReader { scrollProxy in
                        ScrollView {
                            RantList(
                                sourceTab: .feed,
                                rants: dataStore.rantsInFeed,
                                isLoadingMore: viewModel.isLoadingMore,
                                loadMore: {
                                    Task {
                                        await viewModel.loadMore()
                                    }
                                }
                            )
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
