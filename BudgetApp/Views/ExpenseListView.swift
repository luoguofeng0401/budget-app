//
//  ExpenseListView.swift
//  BudgetApp
//
//  Created by Guofeng Luo on 2026/8/18.
//

import SwiftUI

struct ExpenseListView: View {
    
    let expenses:  [Expense]
    // Selection + sheet presentation live on the parent's single `Form` view.
    // Hosting the sheet here (inside the list rows) applied it to every row
    // and made competing presenters dismiss each other on the first tap.
    @Binding var selectedExpense: Expense?
    @Environment(ExpenseTrackerStore.self) private var store
    
    private var tatol: Double {
        expenses.reduce(0) { result, expense in
            result + expense.amount
        }
    }
    
    private func deletExpense(_ indexSet: IndexSet) {
        
        guard let index = indexSet.first else { return }
        let expense = expenses[index]
         
        Task {
            do {
                try await store.deletExpense(expense )
            } catch {
                print(error)
            }
        }
    }
    
    var body: some View {
        if !expenses.isEmpty {
            HStack {
                Spacer()
                Text("Tatol: ")
                Text(tatol, format: .currency(code: Locale.currncyCode))
                Spacer()
            }.bold()
        }
        ForEach(expenses) { expense in
            Button {
                selectedExpense = expense
            } label: {
                ExpenseLCellView(expense: expense)
            }
            .buttonStyle(.plain)
        }
        .onDelete(perform: deletExpense)
    }
}

struct ExpenseLCellView: View {
    
    let expense: Expense
    
    var body: some View {
        
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                Text(expense.name)
                
                if let tags = expense.tags, !tags.isEmpty {
                    TagListView(tags: tags, selectedTags: .constant([]))
                        .font(.caption2)
                }
                
                if expense.receiptPath != nil {
                    Image(systemName: "paperclip")
                }
            }
            Spacer()
            Text(expense.amount ,format: .currency(code: Locale.currncyCode))
        }
    }
}

#Preview {
    Form {
        ExpenseListView(expenses: [Expense(id: 1, name: "Leo", amount: 4.5, budgetId: 15, tags: [Tag(id: 1, name: "Groceries")]), Expense(id: 2, name: "Leo", amount: 4.5, budgetId: 15, tags: [Tag(id: 2, name: "Groceries")])], selectedExpense: .constant(nil))
    }
    .environment(ExpenseTrackerStore(supabaseClient: .development ))
}
