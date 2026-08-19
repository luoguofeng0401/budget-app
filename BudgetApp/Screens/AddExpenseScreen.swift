//
//  AddExpenseScreen.swift
//  BudgetApp
//
//  Created by Guofeng Luo on 2026/8/18.
//

import SwiftUI

struct AddExpenseScreen: View {
    
    let budget: Budget
    
    @State private var name: String = ""
    @State private var amount: Double?
     
    @Environment(\.dismiss) private var dismiss
    @Environment(ExpenseTrackerStore.self) private var store
    
    private func saveExpense() async {
        guard let amount = amount,
              let budgetID = budget.id
                else{ return }
        
        let expense = Expense(name: name, amount: amount, budgetId: budgetID)
        
        do {
            try await store.addExpense(expense)
            dismiss()
        } catch {
            print(error)
        }
    }
    
    var body: some View {
        Form {
            TextField("Enter name", text: $name)
            TextField("Enter limit", value: $amount, format: .number )
        }.toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Close") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    Task {
                        await saveExpense() 
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack{
        AddExpenseScreen(budget: Budget(id: 9, name: "Hiiiii", limit: 350, userID: UUID()))
            .environment(ExpenseTrackerStore(supabaseClient: .development )) 
    }
}
