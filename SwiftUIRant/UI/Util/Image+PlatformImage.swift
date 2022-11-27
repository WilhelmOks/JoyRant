//
//  Image+PlatformImage.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 27.11.22.
//

import SwiftUI

extension Image {
    init(platformImage: PlatformImage) {
        #if os(iOS)
        self.init(uiImage: platformImage)
        #elseif os(macOS)
        self.init(nsImage: platformImage)
        #endif
    }
}
