//
//  Expense.swift
//  BudgetApp
//
//  Created by Guofeng Luo on 2026/8/18.
//

import Foundation

struct Expense: Codable, Identifiable {
    
    var id: Int?
    let name: String
    let amount: Double
    let budgetId: Int
    
    private enum CodingKeys: String, CodingKey  {
        case id = "id"
        case name = "name"
        case amount = "amount"
        case budgetId = "budget_id"
    }
}
