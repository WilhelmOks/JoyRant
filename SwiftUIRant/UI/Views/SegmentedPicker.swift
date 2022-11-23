//
//  SegmentedPicker.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 13.11.22.
//

import SwiftUI

struct SegmentedPicker<Item, ItemView: View>: View {
    @Binding var selectedIndex: Int
    let items: [Item]
    
    var spacing: CGFloat = 10
    var horizontalScrolling: Bool = true
    var innerHorizontalPadding: CGFloat = 10
    
    struct Segment {
        let item: Item
        let selected: Bool
    }
    
    @ViewBuilder let itemView: (Segment) -> (ItemView)
    
    var body: some View {
        if horizontalScrolling {
            ScrollView(.horizontal, showsIndicators: false) {
                content()
            }
        } else {
            content()
        }
    }
    
    @ViewBuilder private func content() -> some View {
        HStack(spacing: spacing) {
            ForEach(items.indices, id: \.self) { index in
                Button {
                    selectedIndex = index
                } label: {
                    itemView(.init(item: items[index], selected: selectedIndex == index))
                }
                //TODO: add accessibility trait for isSelected
            }
        }
        .padding(.horizontal, innerHorizontalPadding)
    }
}

private struct ExampleView: View {
    @State private var currentIndex: Int = 0
    
    var body: some View {
        SegmentedPicker(selectedIndex: $currentIndex, items: ["Bacon", "Ipsum", "Dolor"]) { segment in
            Text(segment.item)
                .if(segment.selected) { $0.bold() }
        }
        .buttonStyle(.plain)
    }
}

struct SegmentedPicker_Previews: PreviewProvider {
    static var previews: some View {
        ExampleView()
            .padding(.vertical)
    }
}
