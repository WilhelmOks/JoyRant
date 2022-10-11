//
//  NotificationsView.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 09.10.22.
//

import SwiftUI

struct NotificationsView: View {
    var navigationBar = true
    
    @ObservedObject private var appState = AppState.shared
    @ObservedObject private var dataStore = DataStore.shared
    @StateObject private var viewModel: NotificationsViewModel = .init()
    
    var body: some View {
        content()
            .if(navigationBar) {
                $0
                .toolbar {
                    ToolbarItem(placement: .automatic) {
                        toolbarReloadButton()
                    }
                }
                .navigationTitle("Notifications")
            }
            .alert($viewModel.alertMessage)
            /*.onAppear {
                Task {
                    await viewModel.load()
                }
            }*/
    }
    
    @ViewBuilder private func content() -> some View {
        VStack {
            Picker(selection: $viewModel.categoryTab, label: EmptyView()) {
                ForEach(viewModel.tabs) { tab in
                    Text(tab.displayName).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(10)
            
            ScrollView {
                LazyVStack(spacing: 0) {
                    //TODO: use something else as id
                    ForEach(dataStore.notifications?.items ?? [], id: \.createdTime) { notification in
                        row(notification)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                        Divider()
                    }
                }
            }
        }
    }
    
    @ViewBuilder private func toolbarReloadButton() -> some View {
        ZStack {
            ProgressView()
                .opacity(viewModel.isLoading ? 1 : 0)
                
            Button {
                Task {
                    await viewModel.load()
                }
            } label: {
                Image(systemName: "arrow.clockwise")
                    .frame(width: 26, height: 26)
            }
            .disabled(viewModel.isLoading)
            .opacity(!viewModel.isLoading ? 1 : 0)
        }
    }
    
    @ViewBuilder private func row(_ notification: SwiftRantNotification) -> some View {
        //TODO: fetch this in DataStore
        let userId = notification.uid
        let userInfo = dataStore.notifications?.usernameMap?.array.first(where: { map in map.uidForUsername == String(userId) })
        let userAvatar = userInfo?.avatar ?? .init(backgroundColor: "cccccc", avatarImage: nil)
        let userName = userInfo?.name ?? ""
        
        NotificationRowView(
            userAvatar: userAvatar,
            userName: userName,
            notificationType: notification.type,
            createdTime: notification.createdTime,
            isRead: notification.read == 1
        )
    }
}

struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView()
    }
}
