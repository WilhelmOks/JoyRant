//
//  RefreshButton.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 16.10.22.
//

import SwiftUI

struct RefreshButton: View {
    var withSpinner: Bool = false
    let isLoading: Bool
    let action: () -> ()
    
    var body: some View {
        LoadingButton(withSpinner: withSpinner, isLoading: isLoading, action: action) {
            Image(systemName: "arrow.clockwise")
                .resizable().aspectRatio(contentMode: .fit)
                .frame(width: 26, height: 26)
        }
    }
}

private struct ExampleView: View {
    @State private var isLoading = false
    
    var body: some View {
        RefreshButton(isLoading: isLoading) {
            isLoading = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                isLoading = false
            }
        }
        .toolbar {
            ToolbarItem {
                RefreshButton(isLoading: isLoading) {
                    isLoading = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        isLoading = false
                    }
                }
            }
        }
    }
}

struct RefreshButton_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ExampleView()
        }
    }
}
