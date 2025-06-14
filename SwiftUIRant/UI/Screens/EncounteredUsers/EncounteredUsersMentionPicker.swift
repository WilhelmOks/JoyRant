//
//  EncounteredUsersMentionPicker.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 14.06.25.
//

import SwiftUI
import SwiftDevRant

struct EncounteredUsersMentionPicker: View {
    @Environment(\.dismiss) private var dismiss
    let onUserPicked: (User) -> Void
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(Color.primaryAccent)
                }
            
                Spacer()
                
                Text("Encountered Users")
                    .bold()
                
                Spacer()
                
                Image(systemName: "xmark")
                    .hidden()
            }
            .padding()
            
            ScrollView {
                LazyVStack {
                    let users = EncounteredUsers.shared.users.sorted(by: { $0.name.compare($1.name, options: [.caseInsensitive]) == .orderedAscending })
                    
                    ForEach(users, id: \.self) { user in
                        Button {
                            onUserPicked(user)
                            dismiss()
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
}

#Preview {
    EncounteredUsersMentionPicker { pickedUser in
        
    }
}
