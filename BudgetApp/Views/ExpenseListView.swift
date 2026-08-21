//
//  ExpenseListView.swift
//  BudgetApp
//
//  Created by Guofeng Luo on 2026/8/18.
//

import SwiftUI

struct ExpenseListView: View {
    
    let expenses:  [Expense]
    @State private var selectedExpense: Expense?
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
            ExpenseLCellView(expense: expense)
                .onTapGesture {
                    selectedExpense = expense
                }
        }
        .onDelete(perform: deletExpense)
        .sheet(item: $selectedExpense) { selectedExpense in
            ExpenseDetailScreen(expense: selectedExpense)
                .presentationDetents([.medium])
        }
    }
}

struct ExpenseLCellView: View {
    
    let expense: Expense
    
    var body: some View {
        
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                Text(expense.name)
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
        ExpenseListView(expenses: [Expense(name: "Leo", amount: 4.5, budgetId: 15)])
    }
    .environment(ExpenseTrackerStore(supabaseClient: .development ))
}
