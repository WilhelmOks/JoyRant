//
//  SettingsView.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 08.10.22.
//

import SwiftUI

struct SettingsView: View {
    var navigationBar = true
    
    @State private var alertMessage: AlertMessage = .none()
    @ObservedObject private var appState = AppState.shared
    
    var body: some View {
        content()
            .if(navigationBar) {
                $0
                .navigationTitle("Settings")
            }
            .alert($alertMessage)
            .navigationDestination(for: AppState.NavigationDestination.self) { destination in
                switch destination {
                case .communityProjects:
                    CommunityProjectsView()
                case .userProfile(userId: let userId):
                    ProfileView(
                        sourceTab: .settings,
                        viewModel: .init(
                            userId: userId
                        )
                    )
                default:
                    EmptyView()
                }
            }
    }
    
    @ViewBuilder private func content() -> some View {
        Form {
            Group {
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
                    NavigationLink(value: AppState.NavigationDestination.communityProjects) {
                        Text("Community Projects")
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
    }
}
