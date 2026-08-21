//
//  BudgetDetailScreen.swift
//  BudgetApp
//
//  Created by Guofeng Luo on 2026/8/17.
//

import SwiftUI
import Supabase

struct BudgetDetailScreen: View {
    
    let budget: Budget
     
    @State private var name: String = ""
    @State private var limit: Double?
    @State private var isPresented: Bool = false
     
    @Environment(ExpenseTrackerStore.self) private var store
    
    private var currentBudget: Budget {
        store.budgets.first(where: { $0.id == budget.id }) ?? budget
    }
    
    private func updateBudget() async {
        guard let limit = limit,
              let id = budget.id
        else { return }
        
        let updatedValue = Budget(name: name, limit: limit, userID: budget.userID)
        
        do {
            try await store.updateBudget(id: id, updatedValues: updatedValue)
        } catch {
            print(error)
          }
    }
     
    var body: some View {
        Form {
            TextField("Enter name", text: $name)
            TextField("Enter limit", value: $limit, format: .number )
            Button("Update") {
                Task {
                    await updateBudget()
                }
            }
            
            Section("Expenses") {
                if let expenses = currentBudget.expenses {
                    ExpenseListView(expenses: expenses)
                }
            }
        }
        .onAppear(perform: {
            name = budget.name
            limit = budget.limit
        })
        .navigationTitle(budget.name)
        .sheet(isPresented: $isPresented, content: {
            NavigationStack {
                AddExpenseScreen(budget:budget)
            }
        })
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add Expense") {
                    isPresented = true
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        BudgetDetailScreen(budget: Budget(name: "Leo", limit: 500, userID: UUID()))
    }.environment(\.supabaseClient, .development)
}
