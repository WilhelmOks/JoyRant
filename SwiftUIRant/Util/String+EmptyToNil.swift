//
//  String+EmptyToNil.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 25.11.22.
//

import Foundation

extension String {
    var emptyToNil: String? {
        return self.isEmpty ? nil : self
    }
}
