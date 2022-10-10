//
//  NotificationsView.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 09.10.22.
//

import SwiftUI

struct NotificationsView: View {
    @StateObject private var viewModel: NotificationsViewModel = .init()
    
    var body: some View {
        VStack {
            Picker(selection: $viewModel.currentTab, label: EmptyView()) {
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
            .navigationTitle("Notifications")
        }
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView()
    }
}
