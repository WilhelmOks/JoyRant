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
    
    enum FocusedControl {
        case content
        case tags
    }
    
    @FocusState private var focusedControl: FocusedControl?
    
    private var numberOfAllowedCharacters: Int {
        switch viewModel.kind {
        case .postRant, .editRant(rant: _):
            return 5000
        case .postComment(rantId: _), .editComment(comment: _):
            return 1000
        }
    }
    
    private var numberOfRemainingCharacters: Int {
        numberOfAllowedCharacters - dataStore.writePostContent.utf8.count
    }
    
    private var canSubmit: Bool {
        return
            numberOfRemainingCharacters >= 0 &&
            !dataStore.writePostContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var title: String {
        switch viewModel.kind {
        case .postRant:
            return "New Rant"
        case .editRant(rant: _):
            return "Edit Rant"
        case .postComment(rantId: _), .editComment(comment: _):
            return "Comment"
        }
    }
    
    var body: some View {
        NavigationStack {
            content()
            .padding()
            .navigationTitle(title)
            .navigationBarTitleDisplayModeInline()
            .frame(minWidth: 320, minHeight: 300)
            .disabled(viewModel.isLoading)
            .onTapGesture {
                focusedControl = nil
            }
            .alert($viewModel.alertMessage)
            .toolbar {
                cancelToolbarItem()
                sendToolbarItem()
                titleToolbarItem()
            }
            .onReceive(viewModel.dismiss) {
                presentationMode.wrappedValue.dismiss()
            }
            .onAppear {
                focusedControl = .content
            }
        }
        //.presentationDetents([.large, .medium])
    }
    
    @ViewBuilder private func content() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            TextEditor(text: $dataStore.writePostContent)
                .font(.callout)
                .focused($focusedControl, equals: .content)
                .textFieldStyle(.plain)
                .if(!viewModel.mentionSuggestions.isEmpty) {
                    $0.toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            mentionSuggestions()
                        }
                    }
                }
                .foregroundColor(.primaryForeground)
                .scrollContentBackground(.hidden)
                .background {
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .foregroundColor(.primaryBackground)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .stroke()
                        .foregroundColor(.secondaryForeground.opacity(0.3))
                }
                .onTapGesture {}
            
            HStack(alignment: .top, spacing: 14) {
                remainingCharacters()
                    
                Spacer()
                
                imagePicker()
                
                imagePreview()
                    .overlay {
                        Rectangle().stroke().foregroundColor(.secondaryForeground.opacity(0.3))
                    }
            }
            
            switch viewModel.kind {
            case .postRant, .editRant(rant: _):
                TextField("Tags (comma separated)", text: $viewModel.tags)
                    #if os(iOS)
                    .textInputAutocapitalization(.never)
                    #endif
                    .font(.callout)
                    .focused($focusedControl, equals: .tags)
                    .textFieldStyle(.roundedBorder)
                    .onTapGesture {}
            case .postComment(rantId: _), .editComment(comment: _):
                EmptyView()
            }
        }
    }
    
    @ViewBuilder private func mentionSuggestions() -> some View {
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
                    //let converted = UnsupportedToJpegImageDataConverter.unsupportedToJpeg.convert(data)
                    viewModel.selectedImageData = data
                    viewModel.selectedImage = PlatformImage(data: data)
                }
                isLoadingImage = false
            }
        }
    }
    
    private func existingImageUrl() -> URL? {
        switch viewModel.kind {
        case .editRant(rant: let rant):
            guard let urlString = rant.attachedImage?.url else { return nil }
            return URL(string: urlString)
        case .editComment(comment: let comment):
            guard let urlString = comment.attachedImage?.url else { return nil }
            return URL(string: urlString)
        case .postComment(rantId: _), .postRant:
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
                case .postComment(rantId: _), .postRant:
                    Text("Post")
                case .editComment(comment: _), .editRant(rant: _):
                    Text("Save")
                }
            } icon: {
                Image(systemName: "paperplane.fill")
            }
        }
        .disabled(!canSubmit)
    }
    
    @ViewBuilder private func toolbarTitle() -> some View {
        switch viewModel.kind {
        case .postRant:
            Picker("Post Type", selection: $viewModel.rantKind) {
                ForEach(WritePostViewModel.RantKind.allCases) { rantKind in
                    Text(rantKindName(rantKind)).tag(rantKind)
                }
            }
            .fixedSize()
        case .postComment(rantId: _), .editComment(comment: _), .editRant(rant: _):
            EmptyView()
        }
    }
    
    private func rantKindName(_ rantKind: WritePostViewModel.RantKind) -> String {
        switch rantKind {
        case .rant:     return "Rant/Story"
        case .jokeMeme: return "Joke/Meme"
        case .question: return "Question"
        case .devRant:  return "devRant"
        case .random:   return "Random"
        }
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
    
    private func titleToolbarItem() -> some ToolbarContent {
        #if os(iOS)
        ToolbarItem(placement: .principal) {
            toolbarTitle()
        }
        #else
        ToolbarItem(placement: .automatic) {
            toolbarTitle()
        }
        #endif
    }
}

struct WritePostView_Previews: PreviewProvider {
    static var previews: some View {
        WritePostView(viewModel: .init(kind: .postRant, onSubmitted: {}))
    }
}
