//
//  KeyPathModifiedCopyable.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 06.09.22.
//

import Foundation

protocol KeyPathModifiedCopyable {
    
}

extension KeyPathModifiedCopyable {
    /// Returns a copy of the caller with a new `value` for the specified `keyPath`.
    func with<T>(_ keyPath: WritableKeyPath<Self, T>, value: T) -> Self {
        var new = self
        new[keyPath: keyPath] = value
        return new
    }
}
