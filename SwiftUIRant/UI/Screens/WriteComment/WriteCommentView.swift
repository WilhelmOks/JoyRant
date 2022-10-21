//
//  WriteCommentView.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 18.10.22.
//

import SwiftUI

struct WriteCommentView: View {
    @Environment(\.presentationMode) private var presentationMode
    
    @StateObject private var viewModel: WriteCommentViewModel = .init()
    
    //TODO: add image preview
    
    var body: some View {
        NavigationStack {
            content()
            .padding()
            .navigationTitle("Comment")
            .navigationBarTitleDisplayModeInline()
            .frame(minWidth: 320, minHeight: 300)
            .toolbar {
                cancelToolbarItem()
            }
        }
    }
    
    @ViewBuilder private func content() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            TextEditor(text: .constant("Placeholder"))
                .foregroundColor(.primaryForeground)
                .overlay {
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .stroke()
                        .foregroundColor(.secondaryForeground)
                }
        }
    }
    
    @ViewBuilder private func cancelButton() -> some View {
        Button {
            presentationMode.wrappedValue.dismiss()
        } label: {
            Label {
                Text("Cancel")
            } icon: {
                Image(systemName: "xmark")
            }
        }
    }
    
    private func cancelToolbarItem() -> some ToolbarContent {
        #if os(iOS)
        ToolbarItem(placement: .navigationBarLeading) {
            cancelButton()
        }
        #else
        ToolbarItem(placement: .automatic) {
            cancelButton()
        }
        #endif
    }
}

struct WriteCommentView_Previews: PreviewProvider {
    static var previews: some View {
        WriteCommentView()
    }
}
