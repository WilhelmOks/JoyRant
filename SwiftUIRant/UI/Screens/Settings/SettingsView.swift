//
//  SettingsView.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 08.10.22.
//

import SwiftUI
import SwiftDevRant

struct SettingsView: View {
    var navigationBar = true
    
    @State private var alertMessage: AlertMessage = .none()
    @ObservedObject private var appState = AppState.shared
    
    enum DownvoteReasonItem: Int, Hashable, CaseIterable {
        case alwaysAsk = -1
        case notForMe = 0
        case repost = 1
        case offensiveOrSpam = 2
        
        var displayName: String {
            switch self {
            case .alwaysAsk: return "(Always ask)"
            case .repost: return "Repost"
            case .offensiveOrSpam: return "Offensive or spam"
            case .notForMe: return "Not for me"
            }
        }
    }
    
    @State private var downvoteReason: DownvoteReasonItem = .alwaysAsk
    
    @State private var reduceVisibilityOfSpam = UserSettings().reduceVisibilityOfSpam
    @State private var showAuthorsInFeed = UserSettings().showAuthorsInFeed
    
    var body: some View {
        content()
            .if(navigationBar) {
                $0
                .navigationTitle("Settings")
            }
            .alert($alertMessage)
            .navigationDestination(for: AppState.NavigationDestination.self) { destination in
                switch destination {
                case .rantDetails(rantId: let rantId, scrollToCommentWithId: let scrollToCommentWithId):
                    RantDetailsView(
                        sourceTab: .feed,
                        viewModel: .init(
                            rantId: rantId,
                            scrollToCommentWithId: scrollToCommentWithId
                        )
                    )
                case .userProfile(userId: let userId):
                    ProfileView(
                        sourceTab: .settings,
                        viewModel: .init(
                            userId: userId
                        )
                    )
                case .communityProjects:
                    CommunityProjectsView()
                case .encounteredUserProfiles:
                    EncounteredUsersProfilePicker()
                case .ignoredUsers:
                    IgnoredUsersView()
                default:
                    EmptyView()
                }
            }
            .onChange(of: downvoteReason) { newValue in
                AppState.shared.automaticDownvoteReason = .init(rawValue: newValue.rawValue)
            }
            .onChange(of: reduceVisibilityOfSpam) { newValue in
                UserSettings().reduceVisibilityOfSpam = newValue
            }
            .onChange(of: showAuthorsInFeed) { newValue in
                UserSettings().showAuthorsInFeed = newValue
            }
            .onAppear {
                let reasonRaw = AppState.shared.automaticDownvoteReason?.rawValue
                downvoteReason = reasonRaw.flatMap { DownvoteReasonItem(rawValue: $0) } ?? .alwaysAsk
            }
    }
    
    @ViewBuilder private func content() -> some View {
        Form {
            Group {
                if let userId = LoginStore.shared.token?.userId {
                    Section {
                        NavigationLink(value: AppState.NavigationDestination.userProfile(userId: userId)) {
                            Label {
                                Text("My Profile")
                            } icon: {
                                Image(systemName: "person")
                            }
                        }
                        
                        NavigationLink(value: AppState.NavigationDestination.encounteredUserProfiles) {
                            Label {
                                Text("Encountered Profiles")
                            } icon: {
                                Image(systemName: "person.badge.clock")
                            }
                        }
                        
                        NavigationLink(value: AppState.NavigationDestination.ignoredUsers) {
                            Label {
                                Text("Ignored Users")
                            } icon: {
                                Image(systemName: "person.badge.minus")
                            }
                        }
                    }
                }
                
                Section {
                    Button {
                        DispatchQueue.main.async {
                            AppState.shared.clearImageCache()
                            alertMessage = .presentedMessage("Image cache cleared.")
                        }
                    } label: {
                        Label {
                            Text("Clear image cache")
                        } icon: {
                            Image(systemName: "photo.on.rectangle.angled")
                        }
                    }
                }
                
                Section("Accent Color") {
                    let colorSelection = Binding<CGColor>(
                        get: {
                            appState.customAccentColor ?? PlatformColor(Color.accentColor).cgColor
                        },
                        set: { newValue in
                            DispatchQueue.main.async {
                                appState.customAccentColor = newValue
                                appState.applyAccentColor()
                            }
                        }
                    )
                    
                    ColorPicker(selection: colorSelection, supportsOpacity: false) {
                        Label {
                            Text("Custom color")
                        } icon: {
                            Image(systemName: "paintbrush.fill")
                        }
                    }
                    
                    Button {
                        DispatchQueue.main.async {
                            appState.customAccentColor = nil
                            appState.applyAccentColor()
                        }
                    } label: {
                        Label {
                            Text("Reset to default")
                        } icon: {
                            Image(systemName: "paintbrush")
                        }
                    }
                }
                
                Section {
                    Picker.init("Downvote reason", selection: $downvoteReason) {
                        ForEach(DownvoteReasonItem.allCases, id: \.self) { item in
                            Text(item.displayName).tag(item)
                        }
                    }
                }
                
                Section {
                    Toggle(isOn: $showAuthorsInFeed) {
                        Text("Show rant authors in feed")
                    }
                    .tint(Color.accentColor)
                    
                    Toggle(isOn: $reduceVisibilityOfSpam) {
                        Text("Reduce visibility of spam")
                    }
                    .tint(Color.accentColor)
                }
                
                Section {
                    NavigationLink(value: AppState.NavigationDestination.communityProjects) {
                        Label {
                            Text("Community Projects")
                        } icon: {
                            Image(systemName: "network")
                        }
                    }
                }
                
                Section {
                    Button {
                        DispatchQueue.main.async {
                            Networking.shared.logOut()
                        }
                    } label: {
                        Label {
                            Text("Log out")
                        } icon: {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                        }
                    }
                }
            }
            .foregroundColor(.primaryForeground)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsView()
        }
        .onAppear {
            LoginStore.shared.token = .init(id: 0, key: "", expireTime: Date(), userId: 0)
        }
    }
}
