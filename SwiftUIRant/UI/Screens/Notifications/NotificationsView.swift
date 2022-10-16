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
                    LoadingButton(isLoading: viewModel.isLoading) {
                        Task {
                            await viewModel.clear()
                        }
                    } label: {
                        Text("Clear")
                    }
                    
                    RefreshButton(isLoading: viewModel.isLoading) {
                        Task {
                            await viewModel.load()
                        }
                    }
                }
                .navigationTitle("Notifications")
            }
            .background(Color.primaryBackground)
            .alert($viewModel.alertMessage)
            .onReceive(broadcastEvent: .shouldRefreshNotifications) { _ in
                Task {
                    await viewModel.refresh()
                }
                Task {
                    try? await DataLoader.shared.loadNumbersOfUnreadNotifications()
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
            .disabled(viewModel.isLoading)
            .padding(10)
            
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.notificationItems) { item in
                        VStack(spacing: 0) {
                            NavigationLink {
                                RantDetailsView(
                                    viewModel: .init(
                                        rantId: item.rantId,
                                        scrollToCommentWithId: item.commentId,
                                        scrollToLastCommentWithUserId: item.notificationType == .commentDiscuss ? item.userId : nil
                                    )
                                )
                            } label: {
                                NotificationRowView(item: item)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                            }
                            .buttonStyle(.plain)
                            
                            Divider()
                        }
                    }
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
