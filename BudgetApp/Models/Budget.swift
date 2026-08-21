//
//  Budget.swift
//  BudgetApp
//
//  Created by Guofeng Luo on 2026/8/17.
//

import Foundation

struct Budget: Codable, Identifiable {
    var id: Int?
    var name: String
    var limit: Double
    var userID: UUID
    var expenses: [Expense]?
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case limit = "limit"
        case userID = "user_id"
        case expenses = "expenses"
    }
}
