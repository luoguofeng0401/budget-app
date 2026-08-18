//
//  Locale+Extensions.swift
//  BudgetApp
//
//  Created by Guofeng Luo on 2026/8/18.
//

import Foundation
 

extension Locale {
    
    static var currncyCode: String {
        Locale.current.currency?.identifier ?? "USD"
    }
}
