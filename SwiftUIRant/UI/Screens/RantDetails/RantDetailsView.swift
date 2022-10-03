//
//  RantDetailsView.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 17.09.22.
//

import SwiftUI
import SwiftRant

struct RantDetailsView: View {
    @StateObject var viewModel: RantDetailsViewModel
        
    var body: some View {
        content()
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    toolbarReloadButton()
                }
                
                ToolbarItem(placement: .automatic) {
                    toolbarMoreButton()
                }
            }
            .navigationTitle("Rant")
            .alert($viewModel.alertMessage)
    }
    
    @ViewBuilder private func content() -> some View {
        if let rant = viewModel.rant, !viewModel.isLoading {
            ScrollView {
                LazyVStack {
                    RantView(
                        viewModel: .init(
                            rant: rant
                        )
                    )
                    .id(rant.uuid)
                    
                    ForEach(viewModel.comments, id: \.id) { comment in
                        VStack(spacing: 0) {
                            Divider()
                            
                            RantCommentView(
                                viewModel: .init(
                                    comment: comment
                                )
                            )
                            //.id(comment.uuid) //TODO: make uuid public
                            .id("\(rant.uuid.uuidString)_ \(comment.id)")
                        }
                    }
                }
                .padding(.bottom, 10)
            }
        } else {
            ProgressView()
        }
    }
    
    @ViewBuilder private func toolbarReloadButton() -> some View {
        ZStack {
            ProgressView()
                .opacity(viewModel.isReloading ? 1 : 0)
                
            Button {
                Task {
                    await viewModel.reload()
                }
            } label: {
                Image(systemName: "arrow.clockwise")
                    .frame(width: 26, height: 26)
            }
            .disabled(viewModel.isLoading)
            .opacity(!viewModel.isReloading ? 1 : 0)
        }
    }
    
    @ViewBuilder private func toolbarMoreButton() -> some View {
        Button {
            //TODO: ...
            viewModel.alertMessage = .presentedError(message: "Not implemented yet.")
        } label: {
            Image(systemName: "ellipsis")
                .frame(width: 26, height: 26)
        }
        .disabled(viewModel.isLoading)
    }
}

struct RantDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        RantDetailsView(
            viewModel: .init(
                rantId: 1
            )
        )
    }
}
