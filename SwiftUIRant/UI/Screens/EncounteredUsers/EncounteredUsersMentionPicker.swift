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
            
            EncounteredUsersList { selectedUser in
                onUserPicked(selectedUser)
                dismiss()
            }
        }
    }
}

#Preview {
    EncounteredUsersMentionPicker { pickedUser in
        
    }
}
