//
//  ContentView.swift
//  BudgetApp
//
//  Created by Guofeng Luo on 2026/8/17.
//

import SwiftUI
import Supabase

struct BudgetListScreen: View {
    
    @State private var isPresented: Bool = false
    @State private var isSettingsPresented: Bool = false
    
    @Environment(ExpenseTrackerStore.self) private var store
    
    
    
    //
    var body: some View {
        List {
            ForEach(store.budgets) { budget in
                
                NavigationLink {
                    BudgetDetailScreen(budget: budget)
                } label: {
                    BudgetCellView(budget: budget)
                }
            }
            .onDelete(perform: { IndexSet in
                guard let index = IndexSet.last else { return }
                let budget = store.budgets[index]
                Task {
                    do {
                        try await  store.deletBudget(budget)
                    } catch {
                        print(error)
                    }
                    
                }
            })
        }
        .navigationBarBackButtonHidden()
        .task {
            do{
                try  await store.lodBudgets()
            } catch {
                print(error)
            }
        }
        .navigationTitle("Budgets")
        .toolbar (content: {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    isSettingsPresented = true
                }, label: {
                    Image(systemName: "gear")
                })
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add New") {
                    isPresented = true
                }
            }
        })
        .sheet(isPresented: $isSettingsPresented, content: {
            SettingsScreen()
        })
        .sheet(isPresented: $isPresented, content: {
            NavigationStack {
                AddBedgetScreen()
            }
        })
    }
}

struct BudgetCellView: View {
    var budget: Budget
    var body: some View {
        HStack {
            Text(budget.name)
            Spacer()
            Text(budget.limit, format: .currency(code: Locale.currncyCode ))
        }
    }
}

#Preview {
    NavigationStack {
        BudgetListScreen()
    }.environment(ExpenseTrackerStore(supabaseClient: .development ))
}
