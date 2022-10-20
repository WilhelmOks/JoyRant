//
//  AppState.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 29.08.22.
//

import Foundation
import SwiftRant
import SwiftUI

#if os(iOS)
import UIKit
#endif

final class AppState: ObservableObject {
    static let shared = AppState()
    
    enum NavigationDestination: Hashable {
        case rantDetails(rantId: Int)
    }
    
    @Published var navigationPath: [NavigationDestination] = []
        
    var isLoggedIn: Bool {
        LoginStore.shared.isLoggedIn
    }
    
    func clearImageCache() {
        URLCache.postedImageCache.removeAllCachedResponses()
        URLCache.userAvatarCache.removeAllCachedResponses()
    }
    
    func applyAccentColor() {
        #if os(iOS)
            DispatchQueue.main.async {
                UIApplication.shared.windows.forEach { window in
                    window.tintColor = UIColor(Color("AccentColor"))
                }
            }
        #endif
    }
}
