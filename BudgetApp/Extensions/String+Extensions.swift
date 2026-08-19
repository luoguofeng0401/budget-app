//
//  String+Extensions.swift
//  BudgetApp
//
//  Created by Guofeng Luo on 2026/8/19.
//

import Foundation
 
extension String {
    
    var isEmptyOrWhiteSpace: Bool {
        trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var isEmail: Bool {
        guard !isEmptyOrWhiteSpace else { return false}
        
        let emailRegEx = "^[A-Z0-9a-z._%+-]+@[A-Z0-9a-z._]+\\.[A-Za-z]{2,}$"
        
        let emailPredcate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPredcate.evaluate(with: self) 
    }
}
