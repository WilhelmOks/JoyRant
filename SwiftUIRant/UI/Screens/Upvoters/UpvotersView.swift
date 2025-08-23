//
//  UpvotersView.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 17.08.25.
//

import SwiftUI

struct UpvotersView: View {
    @Environment(\.dismiss) private var dismiss
    
    var upvoters: [String] = []
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(upvoters, id: \.self) { upvoter in
                    Text(upvoter)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .navigationTitle("Recent upvoters")
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

#Preview {
    NavigationStack {
        UpvotersView(upvoters: ["Bob", "Max", "Anna"])
            .navigationBarTitleDisplayModeInline()
    }
}
