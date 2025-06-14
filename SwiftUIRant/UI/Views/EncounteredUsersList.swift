//
//  EncounteredUsersList.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 14.06.25.
//

import SwiftUI
import SwiftDevRant
import SwiftData

struct EncounteredUsersList: View {
    @Query var users: [User.DataModel]
    
    let onUserSelected: (User) -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack {
                let users = self.users.map(\.domainModel).sorted {
                    $0.name.compare($1.name, options: [.caseInsensitive]) == .orderedAscending
                }
                
                ForEach(users, id: \.self) { user in
                    Button {
                        onUserSelected(user)
                    } label: {
                        HStack {
                            UserPanel(
                                avatar: user.avatarSmall,
                                name: user.name,
                                score: user.score,
                                isSupporter: user.devRantSupporter
                            )
                            
                            Spacer()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 1)
                }
            }
        }
    }
}

#Preview {
    let _ = {
        let user1 = Rant.mocked().author
        EncounteredUsers.shared.update(user: user1)
    }()
    
    EncounteredUsersList { _ in }
}
