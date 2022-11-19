//
//  URLHandler.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 19.11.22.
//

import Foundation

struct URLHandler {
    func navigationDestination(forUrl url: URL) -> AppState.NavigationDestination? {
        guard url.scheme == "joyrant" else { return nil }
        
        switch url.host {
        case "rant":
            guard let rantId = url.pathComponents.last.flatMap(Int.init) else {
                dlog("Rant ID could not be parsed: \(url)")
                return nil
            }
            return .rantDetails(rantId: rantId)
        case "profile":
            guard let userId = url.pathComponents.last.flatMap(Int.init) else {
                dlog("User ID could not be parsed: \(url)")
                return nil
            }
            return .userProfile(userId: userId)
        default:
            return nil
        }
    }
}
