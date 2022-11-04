//
//  NotificationsView.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 09.10.22.
//

import SwiftUI
import SwiftRant

struct NotificationsView: View {
    var navigationBar = true
    
    @StateObject private var viewModel: NotificationsViewModel = .init()
    
    @ObservedObject private var appState = AppState.shared
    @ObservedObject private var dataStore = DataStore.shared
    
    var body: some View {
        content()
            .if(navigationBar) {
                $0
                .toolbar {
                    LoadingButton(isLoading: viewModel.isLoading || viewModel.isRefreshing) {
                        Task {
                            await viewModel.clear()
                        }
                    } label: {
                        Text("Clear")
                    }
                    
                    #if os(macOS)
                    LoadingButton(isLoading: viewModel.isLoading || viewModel.isRefreshing) {
                        Task {
                            await viewModel.refresh()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    #endif
                }
                .navigationTitle("Notifications")
            }
            .background(Color.primaryBackground)
            .alert($viewModel.alertMessage)
            .onReceive(broadcastEvent: .shouldRefreshNotifications) { _ in
                Task {
                    await viewModel.refresh()
                }
            }
            .onReceive(broadcastEvent: .didSwitchToMainTab(.notifications)) { _ in
                if viewModel.isLoaded {
                    Task {
                        await viewModel.refresh()
                    }
                }
            }
            .onReceive(broadcastEvent: .didReselectMainTab(.notifications)) { _ in
                if AppState.shared.notificationsNavigationPath.isEmpty {
                    DispatchQueue.main.async {
                        BroadcastEvent.shouldScrollNotificationsToTop.send()
                    }
                    Task {
                        await viewModel.refresh()
                    }
                }
            }
    }
    
    @ViewBuilder private func content() -> some View {
        VStack {
            Picker(selection: $viewModel.categoryTab, label: EmptyView()) {
                ForEach(viewModel.tabs) { tab in
                    //TODO: The * is temporary just to see if it works
                    let tabTitle = (dataStore.unreadNotifications[tab.category] ?? 0 > 0 ? "* " : "") + tab.displayName
                    Text(tabTitle).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .disabled(viewModel.isLoading || viewModel.isRefreshing)
            .padding(10)
            
            ScrollViewReader { scrollProxy in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.notificationItems, id: \.uuid) { item in
                            VStack(spacing: 0) {
                                NavigationLink(value: item) {
                                    NotificationRowView(item: item)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                }
                                .buttonStyle(.plain)
                                
                                Divider()
                            }
                            .id(item.uuid)
                        }
                    }
                }
                .onReceive(broadcastEvent: .shouldScrollNotificationsToTop) { _ in
                    withAnimation {
                        scrollProxy.scrollTo(viewModel.notificationItems.first?.uuid, anchor: .top)
                    }
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
            .navigationDestination(for: Notifications.MappedNotificationItem.self) { item in
                RantDetailsView(
                    sourceTab: .notifications,
                    viewModel: .init(
                        rantId: item.rantId,
                        scrollToCommentWithId: item.commentId,
                        scrollToLastCommentWithUserId: item.notificationType == .commentDiscuss ? item.userId : nil
                    )
                )
            }
            .navigationDestination(for: AppState.NavigationDestination.self) { item in
                switch item {
                case .rantDetails(rantId: let rantId):
                    RantDetailsView(
                        sourceTab: .notifications,
                        viewModel: .init(rantId: rantId)
                    )
                }
            }
        }
    }
}

struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView()
    }
}
