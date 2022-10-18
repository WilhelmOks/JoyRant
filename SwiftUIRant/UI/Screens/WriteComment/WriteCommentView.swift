//
//  WriteCommentView.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 18.10.22.
//

import SwiftUI

struct WriteCommentView: View {
    @StateObject private var viewModel: WriteCommentViewModel = .init()
    
    //TODO: add a close button
    //TODO: add image preview
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                TextEditor(text: .constant("Placeholder"))
                    .foregroundColor(.primaryForeground)
                    .overlay {
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .stroke()
                            .foregroundColor(.secondaryForeground)
                    }
            }
            .padding()
            .navigationTitle("Comment")
            .navigationBarTitleDisplayModeInline()
            .frame(minWidth: 320, minHeight: 300)
        }
    }
}

struct WriteCommentView_Previews: PreviewProvider {
    static var previews: some View {
        WriteCommentView()
    }
}
