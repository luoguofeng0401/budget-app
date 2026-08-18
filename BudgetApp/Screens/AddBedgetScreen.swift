//
//  AddBedgetScreen.swift
//  BudgetApp
//
//  Created by Guofeng Luo on 2026/8/17.
//

import SwiftUI
import Supabase

struct AddBedgetScreen: View {
    
    @State private var name: String = ""
    @State private var limit: Double?
    
    @Environment(ExpenseTrackerStore.self) private var store
    @Environment(\.dismiss) private var dismiss
     
    
    private func saveBudget() async {
        guard let limit = limit else { return }
        let budget = Budget(name: name, limit: limit)
        
        do {
            try await store.addBudget(budget)
            dismiss() 
        } catch {
            print(error) 
        }
    }
    
    
    var body: some View {
        Form {
            TextField("Enter name", text: $name)
            TextField("Enter lit", value: $limit, format: .number)
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Close") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    Task {
                        await saveBudget()
                    }
                }
                
            }
        }
    }
}

#Preview {
    AddBedgetScreen( )
        .environment(ExpenseTrackerStore(supabaseClient: .development ))
}
