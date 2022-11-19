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
    
    @Environment(\.scenePhase) private var scenePhase
    
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
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active {
                    Task {
                        await viewModel.refresh()
                    }
                }
            }
    }
    
    @ViewBuilder private func content() -> some View {
        VStack(spacing: 0) {
            categoryPicker()
                .padding(.vertical, 10)
            
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
    
    @ViewBuilder private func categoryPicker() -> some View {
        SegmentedPicker(selectedIndex: $viewModel.categoryTabIndex, items: viewModel.tabs) { segment in
            let unread = dataStore.unreadNotifications[segment.item.category] ?? 0 > 0
            HStack(spacing: 4) {
                if unread {
                    Circle()
                        .foregroundColor(.badgeBackground)
                        .frame(width: 6, height: 6)
                }
                
                Text(segment.item.displayName)
                    .font(baseSize: 17, weightDelta: unread ? 2 : 0)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .foregroundColor(segment.selected ? .secondaryBackground : .clear)
                    .animation(.easeOut, value: viewModel.categoryTabIndex)
            }
            .padding(.vertical, 1)
        }
        .buttonStyle(.plain)
        .onChange(of: viewModel.categoryTabIndex) { newValue in
            viewModel.categoryTab = viewModel.tabs[newValue]
        }
        //.disabled(viewModel.isLoading || viewModel.isRefreshing)
    }
}

struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView()
    }
}
