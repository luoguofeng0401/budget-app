//
//  ExpenseTrackerStore.swift
//  BudgetApp
//
//  Created by Guofeng Luo on 2026/8/18.
//

import Foundation
import Observation
import Supabase

@Observable
class ExpenseTrackerStore {
    
    private(set) var budgets: [Budget] = []
    private(set) var expenses: [Expense] = []
    
    var supabaseClient:SupabaseClient
    
    init(supabaseClient: SupabaseClient) {
        self.supabaseClient = supabaseClient
    }
    
    func lodBudgets() async throws{
        
        budgets = try await supabaseClient
            .from("budgets")
            .select("id, name, limit, expenses(id , name, amount, budget_id)")
            .execute()
            .value 
    }
    
    func addBudget(_ budget: Budget) async throws {
        
        let newBudget: Budget = try await supabaseClient
            .from("budgets")
            .insert(budget)
            .select()
            .single()
            .execute() 
            .value
        
        budgets.append(newBudget)
    }
    
    func deletBudget(_ budget: Budget) async throws {
        
        guard let id = budget.id else { return }
        
        try await supabaseClient
            .from("budgets")
            .delete()
            .eq("id", value: id)
            .execute()
        
        budgets = budgets.filter { $0.id! != id }  
        
    }
    
    func updateBudget(id: Int, updatedValues: Budget) async throws    {
     
        let updateBudget: Budget = try await supabaseClient
            .from("budgets")
            .update(updatedValues)
            .eq("id" , value: id)
            .select()
            .single()
            .execute()
            .value
        
        let index = budgets.firstIndex { $0.id ==  id }
        
        if let index {
            budgets[index] = updateBudget 
        }
    }
    
    func addExpense(_ expense: Expense) async throws {
        
        let newExpense: Expense = try await supabaseClient
            .from("expenses")
            .insert(expense)
            .select()
            .single()
            .execute()
            .value
        
        guard let indedx = budgets.firstIndex(where: { $0.id == expense.budgetId }) else {
            throw BudgetError.invalidBudgetID
        }
        
        budgets[indedx].expenses?.append(newExpense)
    }
    
    func deletExpense(_ expense: Expense) async throws {
        
        guard let expenseID = expense.id else {
            throw ExpenseError.invalidExpenseID
         }
        
        try await supabaseClient
            .from("expenses")
            .delete()
            .eq("id", value: expenseID)
            .execute()
        
        guard let index = budgets.firstIndex(where: { $0.id == expense.budgetId}) else {
            throw BudgetError.invalidBudgetID
        }
        
        budgets[index].expenses = budgets[index].expenses?.filter { $0.id != expenseID  }
    }
    
    func updateExpense(expenseID: Int, updatedValues: Expense) async throws {
         
        let updateExpense: Expense = try await supabaseClient
            .from("expenses")
            .update(updatedValues)
            .eq("id", value: expenseID)
            .select()
            .single()  
            .execute()
            .value
        
        guard let budgetIndex = budgets.firstIndex(where: { $0.id == updateExpense.budgetId }) else {
            throw BudgetError.invalidBudgetID
        }
        
        guard let expenseIndex = budgets[budgetIndex].expenses?.firstIndex(where: { $0.id == updateExpense.id }) else {
            throw ExpenseError.invalidExpenseID
        }
        
        budgets[budgetIndex].expenses?[expenseIndex  ] = updateExpense 
    }
}
