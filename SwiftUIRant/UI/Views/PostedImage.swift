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
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            case .failure:
                Image(systemName: "photo")
            @unknown default:
                EmptyView()
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
        let interfaceStyle = UIUserInterfaceStyle(colorScheme)
        let bgColor = interfaceStyle == .dark ? Color.black : Color.white
        let backgroundColor = hexStringFromColor(color: bgColor)
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

private func hexStringFromColor(color: Color) -> String {
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    var opacity: CGFloat = 0.0
    
    guard UIColor(color).getRed(&red, green: &green, blue: &blue, alpha: &opacity) else { return "-" }
    
    let hexString = String(
        format: "#%02lX%02lX%02lX",
        lroundf(Float(red * 255)),
        lroundf(Float(green * 255)),
        lroundf(Float(blue * 255))
    )
    return hexString
}

struct PostedImage_Previews: PreviewProvider {
    static var previews: some View {
        PostedImage(image: .mocked(), opensSheet: true)
    }
}
