//
//  View+Fill.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 06.09.22.
//

import SwiftUI

extension View {
    @ViewBuilder func fill() -> some View {
        self.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ViewBuilder func fill(_ alignment: Alignment) -> some View {
        self.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
    }
    
    @ViewBuilder func fillHorizontally() -> some View {
        self.frame(maxWidth: .infinity)
    }
    
    @ViewBuilder func fillHorizontally(_ alignment: Alignment) -> some View {
        self.frame(maxWidth: .infinity, alignment: alignment)
    }
    
    @ViewBuilder func fillVertically() -> some View {
        self.frame(maxHeight: .infinity)
    }
    
    @ViewBuilder func fillVertically(_ alignment: Alignment) -> some View {
        self.frame(maxHeight: .infinity, alignment: alignment)
    }
}
