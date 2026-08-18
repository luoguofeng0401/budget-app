//
//  ExpenseDetailScreen.swift
//  BudgetApp
//
//  Created by Guofeng Luo on 2026/8/18.
//

import SwiftUI

struct ExpenseDetailScreen: View {
    
    let expense: Expense
    
    @Environment(\.dismiss) private  var dismiss
    @State private var name: String = ""
    @State private var amount: Double?
    
    @Environment(ExpenseTrackerStore.self) private var store
    
    private func updateExpense() async {
        guard let expenseID = expense.id,
              let amount = amount else { return }
        
        let updateValues = Expense(name: name, amount: amount, budgetId: expense.budgetId )
        
        do {
            try await store.updateExpense(expenseID: expenseID, updatedValues: updateValues)
            dismiss()
        } catch {
            print(error)
        }
    }
     
    var body: some View {
        Form {
            TextField("Expense name", text: $name)
            TextField("Expense amount", value: $amount, format: .currency(code: Locale.currncyCode ))
            
            HStack {
                Button("Cancel") {
                    print("dismiss")
                    dismiss()
                }
                
                Spacer()
                
                Button("Update") {
                    Task {
                        await updateExpense()
                    }
                }
            }
        }
        .onAppear(perform: {
            name = expense.name
            amount = expense.amount
        })
    }
}

#Preview {
    ExpenseDetailScreen(expense: Expense(name: "Luo", amount: 2.2, budgetId: 15 ))
        .environment(ExpenseTrackerStore(supabaseClient: .development ))
}
