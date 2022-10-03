//
//  Color+Hex.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 03.10.22.
//

import SwiftUI
import HexUIColor

extension Color {
    init?(hexString: String) {
        guard let uiColor = UIColor.fromHexString(hexString) else {
            return nil
        }
        self.init(uiColor: uiColor)
    }
}
