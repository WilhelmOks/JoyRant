//
//  NotificationsView.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 09.10.22.
//

import SwiftUI

struct NotificationsView: View {
    @ObservedObject private var appState = AppState.shared
    @StateObject private var viewModel: NotificationsViewModel = .init()
    
    var body: some View {
        content()
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    toolbarReloadButton()
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayModeInline()
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
                LazyVStack {
                    
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
}

struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView()
    }
}
