//
//  InsecureAsyncImage.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 18.04.26.
//

import SwiftUI
import SwiftDevRant

/// An AsyncImage alternative that ignores expired certificates for any URL
struct InsecureAsyncImage<Content: View>: View {
    private let url: URL?
    private let scale: CGFloat
    private let urlCache: URLCache
    private let content: (AsyncImagePhase) -> Content

    @StateObject private var loader = Loader()
    
    init(
        url: URL?,
        scale: CGFloat = 1.0,
        urlCache: URLCache,
        @ViewBuilder content: @escaping (AsyncImagePhase) -> Content
    ) {
        self.url = url
        self.scale = scale
        self.urlCache = urlCache
        self.content = content
    }
    
    var body: some View {
        content(loader.phase)
            .onAppear {
                loader.load(url: url, scale: scale, urlCache: urlCache)
            }
            .onChange(of: url) { newValue in
                loader.load(url: newValue, scale: scale, urlCache: urlCache)
            }
    }
}

// MARK: - Loader

extension InsecureAsyncImage {
    @MainActor
    class Loader: ObservableObject {
        @Published var phase: AsyncImagePhase = .empty
        
        private var currentTask: Task<Void, Never>?
        private var lastURL: URL?
        
        func load(url: URL?, scale: CGFloat, urlCache: URLCache) {
            guard url != lastURL else { return }
            lastURL = url
            phase = .empty
            currentTask?.cancel()
            guard let url else { return }
            
            currentTask = Task { [weak self] in
                // Try cache first
                if let cachedResponse = urlCache.cachedResponse(for: URLRequest(url: url)),
                   let image = PlatformImage(data: cachedResponse.data, scale: scale) ?? PlatformImage(data: cachedResponse.data) {
                    await MainActor.run {
                        self?.phase = .success(Image(platformImage: image))
                    }
                    return
                }
                
                // Custom SSL-ignoring session
                let sessionDelegate = InsecureSessionDelegate()
                let config = URLSessionConfiguration.default
                config.urlCache = urlCache
                config.requestCachePolicy = .returnCacheDataElseLoad
                let session = URLSession(configuration: config, delegate: sessionDelegate, delegateQueue: nil)
                
                do {
                    let (data, response) = try await session.data(for: URLRequest(url: url))
                    
                    // Cache the response
                    let cachedResponse = CachedURLResponse(response: response, data: data)
                    urlCache.storeCachedResponse(cachedResponse, for: URLRequest(url: url))
                    
                    if let image = PlatformImage(data: data, scale: scale) ?? PlatformImage(data: data) {
                        await MainActor.run {
                            self?.phase = .success(Image(platformImage: image))
                        }
                    } else {
                        await MainActor.run {
                            self?.phase = .failure(NSError(domain: "InsecureAsyncImage", code: -2, userInfo: [NSLocalizedDescriptionKey: "Image decode failed"]))
                        }
                    }
                } catch {
                    await MainActor.run {
                        self?.phase = .failure(error)
                    }
                }
            }
        }
    }
}

// MARK: - InsecureSessionDelegate

fileprivate class InsecureSessionDelegate: NSObject, URLSessionDelegate {
    override init() {
        super.init()
    }
    
    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
           let serverTrust = challenge.protectionSpace.serverTrust {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}

#Preview {
    let avatar = User.Avatar(
        colorHex: "66dddd",
        imageUrlPath: "v-37_c-3_b-6_g-m_9-1_1-4_16-3_3-4_8-1_7-1_5-1_12-4_6-102_10-1_2-39_22-2_15-10_11-1_4-1.jpg"
    )
    InsecureAsyncImage(url: avatar.imageUrl, urlCache: .userAvatarCache) { phase in
        switch phase {
        case .empty:
            ProgressView()
        case .success(let image):
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
        case .failure:
            Image(systemName: "photo.trianglebadge.exclamationmark")
                .imageScale(.large)
        @unknown default:
            Color.clear
        }
    }
}
