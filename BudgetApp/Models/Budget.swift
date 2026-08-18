//
//  Budget.swift
//  BudgetApp
//
//  Created by Guofeng Luo on 2026/8/17.
//

import Foundation

struct Budget: Codable, Identifiable {
    let id: Int?
    let name: String
    let limit: Double
    var expenses: [Expense]?

    init(id: Int? = nil, name: String, limit: Double) {
        self.id = id
        self.name = name
        self.limit = limit 
    }
}
