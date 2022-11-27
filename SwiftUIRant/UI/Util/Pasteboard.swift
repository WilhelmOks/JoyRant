//
//  Pasteboard.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 27.11.22.
//

import Foundation
import UniformTypeIdentifiers
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

struct Pasteboard {
    static let shared = Self()
    
    func copy(_ string: String) {
        #if os(iOS)
        UIPasteboard.general.setValue(string, forPasteboardType: UTType.plainText.identifier)
        #elseif os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(string, forType: .string)
        #endif
    }
}
