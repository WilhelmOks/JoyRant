//
//  CommunityProjectsView.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 07.04.23.
//

import SwiftUI

struct CommunityProjectsView: View {
    @StateObject private var viewModel: CommunityProjectsViewModel = .init()
    
    var body: some View {
        if viewModel.isLoading {
            ProgressView()
        } else {
            content()
                .alert($viewModel.alertMessage)
                .navigationTitle(Text("Community Projects"))
                .searchable(text: $viewModel.searchText)
        }
    }
    
    @ViewBuilder private func content() -> some View {
        ScrollView {
            VStack {
                SegmentedPicker(
                    selectedIndex: $viewModel.selectedTypeIndex,
                    items: viewModel.pickableTypeItems(),
                    spacing: 0
                ) { segment in
                    Text(segment.item.displayName)
                        .font(baseSize: 17, weightDelta: 0)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .foregroundColor(segment.selected ? .secondaryBackground : .primaryBackground)
                                .animation(.easeOut, value: viewModel.selectedTypeIndex)
                        }
                        .padding(.vertical, 1)
                }
                .buttonStyle(.plain)
                
                SegmentedPicker(
                    selectedIndex: $viewModel.selectedOsIndex,
                    items: viewModel.pickableOsItems(),
                    spacing: 0
                ) { segment in
                    Text(segment.item.displayName)
                        .font(baseSize: 17, weightDelta: 0)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .foregroundColor(segment.selected ? .secondaryBackground : .primaryBackground)
                                .animation(.easeOut, value: viewModel.selectedOsIndex)
                        }
                        .padding(.vertical, 1)
                }
                .buttonStyle(.plain)
                
                HStack {
                    Spacer()
                    Toggle(isOn: $viewModel.activeOnly) {
                        Text("active only")
                            .foregroundColor(.primaryForeground)
                    }
                    .padding(.horizontal, 10)
                    .fixedSize()
                    
                }
                .tint(.primaryAccent)
                
                LazyVStack {
                    ForEach(viewModel.items, id: \.self) { item in
                        VStack(spacing: 0) {
                            Divider()
                            CommunityProjectRowView(communityProject: item)
                                .padding(.horizontal, 10)
                                .padding(.top, 10)
                        }
                    }
                }
                .padding(.vertical, 10)
            }
        }
    }
}

struct CommunityProjectsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CommunityProjectsView()
        }
    }
}
