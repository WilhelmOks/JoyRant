//
//  PostedImage.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 10.09.22.
//

import SwiftUI
import CachedAsyncImage
import SwiftRant
import WebKit

struct PostedImage: View {
    let image: Rant.AttachedImage
    let opensSheet: Bool
    
    @State private var isSheetPresented = false
    
    var isGif: Bool {
        image.url.lowercased().hasSuffix(".gif")
    }
    
    var body: some View {
        if opensSheet {
            Button {
                isSheetPresented = true
            } label: {
                imageView()
            }
            .buttonStyle(.plain)
            .sheet(isPresented: $isSheetPresented) {
                if let url = imageURL() {
                    WebImageView(url: url)
                        .frame(minWidth: 320, minHeight: 300)
                }
            }
        } else {
            imageView()
        }
    }
    
    @ViewBuilder private func imageView() -> some View {
        CachedAsyncImage(url: imageURL(), urlCache: .postedImageCache) { phase in
            switch phase {
            case .empty:
                ZStack {
                    let aspectRatio = CGFloat(image.width) / CGFloat(image.height)
                    
                    Rectangle()
                        .fill(Color.clear)
                        .aspectRatio(aspectRatio, contentMode: .fit)
                    
                    ProgressView()
                }
                .frame(maxHeight: 1000)
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .frame(maxHeight: 1000)
            case .failure:
                Image(systemName: "photo")
            @unknown default:
                EmptyView()
            }
        }
        .overlay(alignment: .topLeading) {
            if isGif {
                Text("GIF")
                    .font(baseSize: 14, weightDelta: 2)
                    .foregroundColor(.white)
                    .padding(.vertical, 2)
                    .padding(.horizontal, 5)
                    .background {
                        RoundedRectangle(cornerRadius: 4)
                            .foregroundColor(.gray)
                    }
                    .padding(5)
            }
        }
    }
    
    private func imageURL() -> URL? {
        return URL(string: image.url)
    }
}

private struct WebImageView: View {
    let url: URL
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    var htmlString: String {
        let bgColor = colorScheme == .dark ? Color.black : Color.white
        let backgroundColor = hexStringFromColor(color: PlatformColor(bgColor))
        let style = """
            html, body, #wrapper {
                height: 100%;
                width: 100%;
                margin: 0;
                padding: 0;
                border: 0;
                background-color: \(backgroundColor);
            }
            #wrapper td {
               vertical-align: middle;
               text-align: center;
            }
            """
        let meta = ""
        let head = "<head><style>\(style)</style>\(meta)</head>"
        let htmlBodyContent = """
            <table id="wrapper">
              <tr>
                <td><img src="\(url)" width="100%"></td>
              </tr>
            </table>
            """
        let body = "<body>\(htmlBodyContent)</body>"
        return "<!DOCTYPE html><html>\(head)\(body)</html>"
    }

    var body: some View {
        NavigationStack {
            WebView(htmlString: htmlString)
                .toolbar {
                    cancelToolbarItem()
                }
                .edgesIgnoringSafeArea(.bottom)
        }
    }
    
    @ViewBuilder private func dismissButton() -> some View {
        Button {
            dismiss()
        } label: {
            Label("Cancel", systemImage: "xmark")
        }
    }
    
    private func cancelToolbarItem() -> some ToolbarContent {
        #if os(iOS)
        ToolbarItem(placement: .navigationBarLeading) {
            dismissButton()
        }
        #else
        ToolbarItem(placement: .cancellationAction) {
            dismissButton()
        }
        #endif
    }
}

#if os(iOS)

private struct WebView : UIViewRepresentable {
    let htmlString: String
    
    func makeUIView(context: Context) -> WKWebView  {
        let uiView = WKWebView()
        uiView.backgroundColor = .clear
        return uiView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(htmlString, baseURL: nil)
    }
}

#elseif os(macOS)

private struct WebView : NSViewRepresentable {
    let htmlString: String
    
    func makeNSView(context: Context) -> WKWebView  {
        let uiView = WKWebView()
        return uiView
    }
    
    func updateNSView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(htmlString, baseURL: nil)
    }
}

#endif

struct PostedImage_Previews: PreviewProvider {
    static var previews: some View {
        PostedImage(image: .mocked(), opensSheet: true)
    }
}
