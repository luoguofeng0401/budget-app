//
//  ExpenseDetailScreen.swift
//  BudgetApp
//
//  Created by Guofeng Luo on 2026/8/18.
//

import SwiftUI
public import Storage

struct ExpenseDetailScreen: View {
    
    let expense: Expense
    
    @Environment(\.dismiss) private  var dismiss
    @State private var name: String = ""
    @State private var amount: Double?
    @State private var imageData: Data?
    
    @Environment(ExpenseTrackerStore.self) private var store
    @Environment(\.storageClient) private var storageClient
    
    @State private var loading: Bool = false
    @State private var selectedTags: Set<Tag> = []
    
    private func updateExpense() async {
        guard let expenseID = expense.id,
              let amount = amount else { return }
        
        let updateValues = Expense(name: name, amount: amount, budgetId: expense.budgetId )
        
        do {
            try await store.updateExpense(expenseID: expenseID, updatedValues: updateValues, tags: Array(selectedTags))
            dismiss()
        } catch {
            print(error)
        }
    }
    
    
    private func loadReceipt() async throws{
        guard let receiptPath = expense.receiptPath else { return }
        
        imageData = try await storageClient
            .from("receipts")
            .download(path: receiptPath)
    }
     
    var body: some View {
        Form {
            TextField("Expense name", text: $name)
            TextField("Expense amount", value: $amount, format: .currency(code: Locale.currncyCode ))
            
            AddTagsView(tags: store.tags, selectedTags: $selectedTags, onTagAdded: store.createTag)
            
            HStack {
                Button("Cancel") {
                    print("dismiss")
                    dismiss()
                }
                .buttonStyle(.borderless)
                
                Spacer()
                
                Button("Update") {
                    Task {
                        await updateExpense()
                    }
                }
                .buttonStyle(.borderless)
            }
            
            if loading {
                ProgressView("Loading...")
            } else {
                HStack {
                    Spacer()
                    if let imageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                    Spacer()
                }
            }
        }
        .task {

            loading = true
            
            do {
                try await loadReceipt()
                try await store.loadTags()
            } catch {
                print(error)
            }
            
            loading = false
            
        }
        .onAppear(perform: {
            name = expense.name
            amount = expense.amount
            selectedTags = Set(expense.tags ?? [])
        })
    }
}

#Preview {
    ExpenseDetailScreen(expense: Expense(name: "Luo", amount: 2.2, budgetId: 15 ))
        .environment(ExpenseTrackerStore(supabaseClient: .development ))
        .environment(\.storageClient, .development)
}
