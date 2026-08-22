//
//  AddTAgsView.swift
//  BudgetApp
//
//  Created by Guofeng Luo on 2026/8/21.
//

import SwiftUI

struct AddTagsView: View {
    
    let tags: [Tag]
    @Binding var selectedTags: Set<Tag>
    @State private var newTagName: String = ""
    
    let onTagAdded: (Tag) async throws -> Void
    
    private var tagExists: Bool {
        tags.contains(where: { $0.name.lowercased() == newTagName.lowercased() })
    }
    
    var body: some View {
        HStack {
            TextField("New Tag", text: $newTagName)
                .textFieldStyle(.roundedBorder)
                .fixedSize()
                .onSubmit {
                    if !tagExists && !newTagName.isEmpty {
                        let newTag = Tag(name: newTagName)
                        Task {
                            try await onTagAdded(newTag)
                        }
                    }
                    newTagName = ""
                }
            TagListView(tags: tags, selectedTags: $selectedTags)
        }
    }
}

struct TagsViewContainer: View {
    
    @State var selectedTags: Set<Tag> = []
    
    var body: some View {
        AddTagsView(tags: [Tag(id: 1, name: "Dining Out"), Tag(id: 2, name: "Travel")], selectedTags: $selectedTags, onTagAdded: { _ in })
            .padding()
    }
}

#Preview {
    TagsViewContainer()
}
