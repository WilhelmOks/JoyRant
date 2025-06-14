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
        NavigationStack {
            EncounteredUsersList { selectedUser in
                onUserPicked(selectedUser)
                dismiss()
            }
            .padding(.horizontal, 1)
            .navigationTitle("Encountered Users")
            .navigationBarTitleDisplayModeInline()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(Color.primaryAccent)
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
