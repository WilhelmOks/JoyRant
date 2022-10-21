//
//  WriteCommentView.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 18.10.22.
//

import SwiftUI

struct WriteCommentView: View {
    @Environment(\.presentationMode) private var presentationMode
    
    @StateObject var viewModel: WriteCommentViewModel
    
    @ObservedObject private var dataStore = DataStore.shared
    
    //TODO: add image preview
    
    var body: some View {
        NavigationStack {
            content()
            .padding()
            .navigationTitle("Comment")
            .navigationBarTitleDisplayModeInline()
            .frame(minWidth: 320, minHeight: 300)
            .disabled(viewModel.isLoading)
            .alert($viewModel.alertMessage)
            .toolbar {
                cancelToolbarItem()
                sendToolbarItem()
            }
            .onReceive(viewModel.dismiss) {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    @ViewBuilder private func content() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            TextEditor(text: $dataStore.writeCommentContent)
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
    
    @ViewBuilder private func sendButton() -> some View {
        LoadingButton(isLoading: viewModel.isLoading) {
            Task {
                await viewModel.submit()
            }
        } label: {
            Label {
                Text("Post")
            } icon: {
                Image(systemName: "paperplane.fill")
            }
        }
        .disabled(dataStore.writeCommentContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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
    
    private func sendToolbarItem() -> some ToolbarContent {
        #if os(iOS)
        ToolbarItem(placement: .navigationBarTrailing) {
            sendButton()
        }
        #else
        ToolbarItem(placement: .automatic) {
            sendButton()
        }
        #endif
    }
}

struct WriteCommentView_Previews: PreviewProvider {
    static var previews: some View {
        WriteCommentView(viewModel: .init(kind: .post(rantId: 0), onSubmitted: {}))
    }
}
