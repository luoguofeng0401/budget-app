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
    private(set) var tags: [Tag] = []
    
    private(set) var expenses: [Expense] = []
    
    var supabaseClient: SupabaseClient
    
    init(supabaseClient: SupabaseClient) {
        self.supabaseClient = supabaseClient
    }
    
    func lodBudgets() async throws{
        
        budgets = try await supabaseClient
            .from("budgets")
            .select("id, name, limit, user_id, expenses(id , name, amount, budget_id)")
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
    
    func addExpense(expense: Expense, tags: [Tag]) async throws {
        
        var newExpense: Expense = try await supabaseClient
            .from("expenses")
            .insert(expense)
            .select()
            .single()
            .execute()
            .value
        
        for tag in tags {
            try await supabaseClient
                .from("expenses_tags")
                .insert(["expense_id": newExpense.id, "tag_id": tag.id])
                .execute()
        }
        
        guard let indedx = budgets.firstIndex(where: { $0.id == expense.budgetId }) else {
            throw BudgetError.invalidBudgetID
        }
        
        newExpense.tags = tags
        budgets[indedx].expenses = (budgets[indedx].expenses ?? []) + [newExpense]
    }
    
    func loadExpense(by budgetId: Int) async throws {
        
        let expenses: [Expense] = try await supabaseClient
            .from("expenses")
            .select("id, name, amount, budget_id, receipt_path, tags(id, name")
            .eq("budget_id", value: budgetId)
            .execute()
            .value
        
        guard let index = budgets.firstIndex(where: { $0.id == budgetId }) else {
            throw BudgetError.invalidBudgetID
        }
                                             
        budgets[index].expenses = expenses
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
    
    func updateExpense(expenseID: Int, updatedValues: Expense, tags: [Tag]) async throws {
         
        var updatedExpense: Expense = try await supabaseClient
            .from("expenses")
            .update(updatedValues)
            .eq("id", value: expenseID)
            .select()
            .single()  
            .execute()
            .value
        
        try await supabaseClient
            .from("expenses_tags")
            .delete()
            .eq("expense_id", value: updatedExpense.id)
            .execute()
        
        for tag in tags {
            try await supabaseClient
                .from("expenses_tags")
                .insert(["expense_id": updatedExpense.id, "tag_id": tag.id])
                .execute()
        }
            
        
        guard let budgetIndex = budgets.firstIndex(where: { $0.id == updatedExpense.budgetId }) else {
            throw BudgetError.invalidBudgetID
        }
        
        guard let expenseIndex = budgets[budgetIndex].expenses?.firstIndex(where: { $0.id == updatedExpense.id }) else {
            throw ExpenseError.invalidExpenseID
        }
        
        updatedExpense.tags = tags
        budgets[budgetIndex].expenses?[expenseIndex  ] = updatedExpense
    }
    
    func loadTags() async throws {
        tags = try await supabaseClient
            .from("tags")
            .select()
            .execute()
            .value
    }
    
    func createTag(tag: Tag) async throws {
        
        let newTag: Tag = try await supabaseClient
            .from("tags")
            .insert(tag)
            .select()
            .single()
            .execute()
            .value
        
        tags.insert(newTag, at: 0)
    }
}
