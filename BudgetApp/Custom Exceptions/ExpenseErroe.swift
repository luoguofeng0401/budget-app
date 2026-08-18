//
//  ExpenseErroe.swift
//  BudgetApp
//
//  Created by Guofeng Luo on 2026/8/18.
//

import Foundation

enum ExpenseError: LocalizedError {
    
    case invalidExpenseID
    
    var errorDescription: String? {
        switch self {
        case .invalidExpenseID:
            return "Expense does not have a valid ID."
        }
        
    }
}
