//
//  TagListView.swift
//  BudgetApp
//
//  Created by Guofeng Luo on 2026/8/21.
//

import SwiftUI

struct TagView: View {
    
    let tag: Tag
    @Binding var selectedTags: Set<Tag>
    
    private var backgroundColor: Color {
        if selectedTags.contains(tag) {
            return .orange
        } else {
            return .gray
        }
    }
    
    private func toggleTagselection() {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else {
            selectedTags.insert(tag)
        }
        self.selectedTags = selectedTags
    }
    
    var body: some View {
        Text(tag.name)
            .padding(8)
            .background(backgroundColor)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16.0, style: .continuous))
            .onTapGesture {
                toggleTagselection()
            }
    }
}

struct TagListView: View {
    
    let tags: [Tag]
    @Binding var selectedTags: Set<Tag>
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(tags) { tag in
                    TagView(tag: tag, selectedTags: $selectedTags)
                }
            }
        }
    }
}

#Preview {
    TagListView(tags: [Tag(id:1, name: "Entertainment"), Tag(id:2, name: "Travel")], selectedTags: .constant([]))
}
