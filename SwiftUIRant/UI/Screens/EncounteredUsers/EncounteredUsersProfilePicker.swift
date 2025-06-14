//
//  EncounteredUsersProfilePicker.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 14.06.25.
//

import SwiftUI
import SwiftDevRant

struct EncounteredUsersProfilePicker: View {
    var body: some View {
        content()
            .navigationTitle("Encountered Profiles")
            .navigationDestination(for: AppState.NavigationDestination.self) { destination in
                switch destination {
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
        EncounteredUsersList { selectedUser in
            AppState.shared.navigate(from: .settings, to: .userProfile(userId: selectedUser.id))
        }
    }
}

#Preview {
    EncounteredUsersProfilePicker()
}
