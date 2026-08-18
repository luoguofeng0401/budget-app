//
//  BudgetError.swift
//  BudgetApp
//
//  Created by Guofeng Luo on 2026/8/18.
//

import Foundation

enum BudgetError: LocalizedError {
    
    case invalidBudgetID
    
    var errorDescription: String? {
        switch self {
        case .invalidBudgetID:
            return "Expense does not have a valid budget ID."
        }
        
    }
}
