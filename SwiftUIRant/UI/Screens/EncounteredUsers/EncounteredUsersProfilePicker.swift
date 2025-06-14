//
//  EncounteredUsersProfilePicker.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 14.06.25.
//

import SwiftUI
import SwiftDevRant

struct EncounteredUsersProfilePicker: View {
    @State private var isClearConfirmationPresented = false
    
    var body: some View {
        content()
            .navigationTitle("Encountered Profiles")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isClearConfirmationPresented = true
                    } label: {
                        Text("Clear")
                    }
                    .confirmationDialog(
                        "Delete all encountered profiles?",
                        isPresented: $isClearConfirmationPresented,
                        actions: {
                            Button("Delete", role: .destructive) {
                                EncounteredUsers.shared.clear()
                            }
                        },
                        message: {
                            Text("Delete all encountered profiles?")
                        }
                    )
                }
            }
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
    NavigationStack {
        EncounteredUsersProfilePicker()        
    }
}
