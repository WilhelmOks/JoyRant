//
//  View+NotificationCenter.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 06.09.22.
//

import SwiftUI

extension View {
    func onReceive(notification name: Notification.Name, perform action: @escaping (Notification) -> ()) -> some View {
        self.onReceive(NotificationCenter.default.publisher(for: name, object: nil), perform: action)
    }
}
