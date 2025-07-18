//
//  AppState.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 29.08.22.
//

import Foundation
import SwiftDevRant
import SwiftUI
import SpamDetector

#if os(iOS)
import UIKit
#endif

final class AppState: ObservableObject {
    static let shared = AppState()
    
    enum NavigationDestination: Hashable {
        case rantDetails(rantId: Rant.ID, scrollToCommentWithId: Comment.ID? = nil)
        case userProfile(userId: UserID)
        case rantWeek(week: Weekly)
        case communityProjects
        case encounteredUserProfiles
    }
    
    @Published var feedNavigationPath = NavigationPath()
    @Published var weeklyNavigationPath = NavigationPath()
    @Published var notificationsNavigationPath = NavigationPath()
    @Published var settingsNavigationPath = NavigationPath()
    
    var isLoggedIn: Bool {
        LoginStore.shared.isLoggedIn
    }
    
    func navigate(from sourceTab: InternalView.Tab, to destination: NavigationDestination) {
        switch sourceTab {
        case .feed:
            feedNavigationPath.append(destination)
        case .weekly:
            weeklyNavigationPath.append(destination)
        case .notifications:
            notificationsNavigationPath.append(destination)
        case .settings:
            settingsNavigationPath.append(destination)
        }
    }
    
    func navigateToRoot(from sourceTab: InternalView.Tab) {
        switch sourceTab {
        case .feed:
            feedNavigationPath = .init()
        case .weekly:
            weeklyNavigationPath = .init()
        case .notifications:
            notificationsNavigationPath = .init()
        case .settings:
            settingsNavigationPath = .init()
        }
    }
    
    func navigate(from sourceTab: InternalView.Tab, to url: URL) {
        guard let destination = URLHandler().navigationDestination(forUrl: url) else { return }
        navigate(from: sourceTab, to: destination)
    }
    
    func clearImageCache() {
        URLCache.postedImageCache.removeAllCachedResponses()
        URLCache.profileImageCache.removeAllCachedResponses()
        URLCache.userAvatarCache.removeAllCachedResponses()
    }
    
    var customAccentColor: CGColor? {
        get {
            if let hexString = UserDefaults.standard.string(forKey: "accent_color") {
                return PlatformColor.fromHexString(hexString)?.cgColor
            } else {
                return nil
            }
        }
        set {
            if let newValue {
                #if os(iOS)
                let hexString = hexStringFromColor(color: .init(cgColor: newValue))
                #elseif os(macOS)
                let hexString = hexStringFromColor(color: .init(cgColor: newValue) ?? .init(white: 0.5, alpha: 1))
                #endif
                UserDefaults.standard.set(hexString, forKey: "accent_color")
            } else {
                UserDefaults.standard.removeObject(forKey: "accent_color")
            }
            objectWillChange.send()
        }
    }
    
    func applyAccentColor() {
        #if os(iOS)
            DispatchQueue.main.async {
                UIApplication.shared.windows.forEach { window in
                    window.tintColor = UIColor(Color.primaryAccent)
                }
            }
        #endif
    }
    
    var automaticDownvoteReason: DownvoteReason? {
        get {
            if let reasonNumberString = UserDefaults.standard.string(forKey: "automatic_downvote_reason") {
                return Int(reasonNumberString).flatMap { .init(rawValue: $0) }
            } else {
                return nil
            }
        }
        set {
            if let newValue {
                let reasonNumberString = String(newValue.rawValue)
                UserDefaults.standard.set(reasonNumberString, forKey: "automatic_downvote_reason")
            } else {
                UserDefaults.standard.removeObject(forKey: "automatic_downvote_reason")
            }
            objectWillChange.send()
        }
    }
    
    var spamDetectorConfig: SpamDetector.Config?
    
    func scanForSpam(feed: RantFeed) -> RantFeed {
        guard let spamDetectorConfig else {
            return feed
        }
        
        let spamDetector = SpamDetector(config: spamDetectorConfig)
        
        var rants = feed.rants
        
        for (index, rant) in rants.enumerated() {
            rants[index].spamInfo = .init(
                scanResult: spamDetector.check(rant.text, userReputation: rant.author.score)
            )
        }
        
        let scannedFeed = RantFeed(rants: rants, sessionHash: feed.sessionHash, weeklyRantWeek: feed.weeklyRantWeek, devRantSupporter: feed.devRantSupporter, numberOfUnreadNotifications: feed.numberOfUnreadNotifications, news: feed.news)
        
        return scannedFeed
    }
}
