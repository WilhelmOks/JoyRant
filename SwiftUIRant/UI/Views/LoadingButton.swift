//
//  LoadingButton.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 16.10.22.
//

import SwiftUI

struct LoadingButton<Label: View>: View {
    var withSpinner: Bool = false
    let isLoading: Bool
    let action: () -> ()
    @ViewBuilder let label: () -> Label
    
    var body: some View {
        if withSpinner {
            ZStack(alignment: .center) {
                ProgressView()
                    .frame(width: 26, height: 26)
                    .opacity(isLoading ? 1 : 0)
                
                Button {
                    action()
                } label: {
                    label()
                }
                .disabled(isLoading)
                .opacity(!isLoading ? 1 : 0)
            }
        } else {
            Button {
                action()
            } label: {
                label()
            }
            .disabled(isLoading)
        }
    }
}

private struct ExampleView: View {
    @State private var isLoading = false
    
    var body: some View {
        LoadingButton(isLoading: isLoading) {
            isLoading = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                isLoading = false
            }
        } label: {
            Text("start")
        }
    }
}

struct LoadingButton_Previews: PreviewProvider {
    static var previews: some View {
        ExampleView()
    }
}
