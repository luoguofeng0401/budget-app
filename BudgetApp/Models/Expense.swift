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
    var receiptPath: String?
    var tags: [Tag]?
    
    private enum CodingKeys: String, CodingKey  {
        case id, name, amount, tags
        case budgetId = "budget_id"
        case receiptPath = "receipt_path"
    }
}
