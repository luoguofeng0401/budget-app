//
//  AuthClient+Extensions.swift
//  BudgetApp
//
//  Created by Guofeng Luo on 2026/8/18.
//

import Foundation
import Supabase

extension AuthClient {
    
    static var development: AuthClient {
        SupabaseClient.development.auth
    }
}
