//
//  Color+Hex.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 03.10.22.
//

import SwiftUI

#if os(iOS)
import HexUIColor
#elseif os(OSX)
import HexNSColor
#endif

extension Color {
    init?(hexString: String) {
        #if os(iOS)
        
        guard let uiColor = UIColor.fromHexString(hexString) else {
            return nil
        }
        self.init(uiColor: uiColor)
        
        #elseif os(OSX)
        
        guard let nsColor = NSColor.fromHexString(hexString) else {
            return nil
        }
        self.init(nsColor: nsColor)
        
        #endif
    }
}
