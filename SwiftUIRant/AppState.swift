//
//  AppState.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 29.08.22.
//

import Foundation
import SwiftRant

final class AppState: ObservableObject {
    static let shared = AppState()
    
    enum NavigationDestination: Hashable {
        case rantDetails(rantId: Int)
    }
    
    @Published var navigationPath: [NavigationDestination] = []
    
    var isLoggedIn: Bool {
        SwiftRant.shared.tokenFromKeychain != nil
    }
    
    func clearImageCache() { //TODO: call from UI
        URLCache.postedImageCache.removeAllCachedResponses()
        URLCache.userAvatarCache.removeAllCachedResponses()
    }
}
