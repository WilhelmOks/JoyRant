//
//  WritePostView.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 18.10.22.
//

import SwiftUI
import PhotosUI
import CachedAsyncImage

#if os(iOS)
import UIKit
typealias PlatformImage = UIImage
#elseif os(macOS)
import AppKit
typealias PlatformImage = NSImage
#endif

struct WritePostView: View {
    @Environment(\.presentationMode) private var presentationMode
    
    @StateObject var viewModel: WritePostViewModel
    
    @ObservedObject private var dataStore = DataStore.shared
    
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    
    @State private var isLoadingImage = false
    
    @FocusState private var isTextEditorFocused
    
    private let numberOfAllowedCharacters = 1000
    
    private var numberOfRemainingCharacters: Int {
        numberOfAllowedCharacters - dataStore.writePostContent.utf8.count
    }
    
    private var canSubmit: Bool {
        return
            numberOfRemainingCharacters >= 0 &&
            !dataStore.writePostContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            content()
            .padding()
            .navigationTitle("Comment") //TODO: change title based on kind
            .navigationBarTitleDisplayModeInline()
            .frame(minWidth: 320, minHeight: 300)
            .disabled(viewModel.isLoading)
            .onTapGesture {
                isTextEditorFocused = false
            }
            .alert($viewModel.alertMessage)
            .toolbar {
                cancelToolbarItem()
                sendToolbarItem()
            }
            .onReceive(viewModel.dismiss) {
                presentationMode.wrappedValue.dismiss()
            }
            .onAppear {
                isTextEditorFocused = true
            }
        }
        //.presentationDetents([.large, .medium])
    }
    
    @ViewBuilder private func content() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            TextEditor(text: $dataStore.writePostContent)
                .font(.callout)
                .focused($isTextEditorFocused)
                .if(!viewModel.mentionSuggestions.isEmpty) {
                    $0.toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(viewModel.mentionSuggestions, id: \.self) { suggestion in
                                        Button {
                                            DataStore.shared.writePostContent.append(suggestion + " ")
                                        } label: {
                                            Text(suggestion)
                                                .padding(.vertical, 8)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .foregroundColor(.primaryForeground)
                .overlay {
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .stroke()
                        .foregroundColor(.secondaryForeground)
                }
                .onTapGesture {}
            
            HStack(alignment: .top, spacing: 14) {
                remainingCharacters()
                    
                Spacer()
                
                imagePicker()
                
                imagePreview()
                    .overlay {
                        Rectangle().stroke().foregroundColor(.secondaryForeground)
                    }
            }
        }
    }
    
    @ViewBuilder private func remainingCharacters() -> some View {
        Text("\(numberOfRemainingCharacters)")
            .font(baseSize: 13, weightDelta: 2)
            .foregroundColor(.secondaryForeground)
    }
    
    @ViewBuilder private func imagePicker() -> some View {
        PhotosPicker(selection: $selectedPhotoItem, matching: .any(of: [.images]), photoLibrary: .shared()) {
            Label {
                Text("Attach image")
            } icon: {
                Image(systemName: "photo")
            }
            .font(baseSize: 16, weightDelta: 1)
        }
        .disabled(existingImageUrl() != nil)
        .onChange(of: selectedPhotoItem) { newValue in
            Task {
                isLoadingImage = true
                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                    viewModel.selectedImageData = data
                    viewModel.selectedImage = PlatformImage(data: data)
                }
                isLoadingImage = false
            }
        }
    }
    
    private func existingImageUrl() -> URL? {
        switch viewModel.kind {
        case .edit(comment: let comment):
            guard let urlString = comment.attachedImage?.url else { return nil }
            return URL(string: urlString)
        case .post(rantId: _):
            return nil
        }
    }
    
    @ViewBuilder private func imagePreview() -> some View {
        if let image = viewModel.selectedImage {
            imagePreview(platformImage: image)
        } else if let url = existingImageUrl() {
            imagePreview(url: url)
        } else if isLoadingImage {
            imagePreviewProgress()
        }
    }
    
    @ViewBuilder private func imagePreviewProgress(size: CGFloat = 50) -> some View {
        ProgressView()
            .frame(width: size, height: size)
    }
    
    @ViewBuilder private func imagePreview(url: URL, size: CGFloat = 50) -> some View {
        CachedAsyncImage(url: url, urlCache: .postedImageCache) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .frame(width: size, height: size)
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size, height: size)
            case .failure:
                Image(systemName: "exclamationmark.triangle")
            @unknown default:
                EmptyView()
            }
        }
        .frame(width: size, height: size)
    }
    
    @ViewBuilder private func imagePreview(platformImage: PlatformImage, size: CGFloat = 50) -> some View {
        image(platformImage: platformImage)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
    }
    
    private func image(platformImage: PlatformImage) -> Image {
        #if os(iOS)
        Image(uiImage: platformImage)
        #elseif os(macOS)
        Image(nsImage: platformImage)
        #endif
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
        LoadingButton(withSpinner: true, isLoading: viewModel.isLoading) {
            Task {
                await viewModel.submit()
            }
        } label: {
            Label {
                switch viewModel.kind {
                case .post(rantId: _):
                    Text("Post")
                case .edit(comment: _):
                    Text("Save")
                }
            } icon: {
                Image(systemName: "paperplane.fill")
            }
        }
        .disabled(!canSubmit)
    }
    
    private func cancelToolbarItem() -> some ToolbarContent {
        #if os(iOS)
        ToolbarItem(placement: .navigationBarLeading) {
            cancelButton()
        }
        #else
        ToolbarItem(placement: .cancellationAction) {
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
        ToolbarItem(placement: .confirmationAction) {
            sendButton()
        }
        #endif
    }
}

struct WritePostView_Previews: PreviewProvider {
    static var previews: some View {
        WritePostView(viewModel: .init(kind: .post(rantId: 0), onSubmitted: {}))
    }
}
