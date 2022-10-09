//
//  NotificationsView.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 09.10.22.
//

import SwiftUI

struct NotificationsView: View {
    var body: some View {
        VStack {
            Text("TODO: filter picker")
            
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
