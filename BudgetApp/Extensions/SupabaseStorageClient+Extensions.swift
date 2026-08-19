//
//  SupabaseStorageClient+Extensions.swift
//  BudgetApp
//
//  Created by Guofeng Luo on 2026/8/19.
//

import Foundation
import Supabase

extension SupabaseStorageClient {
    
    static var development: SupabaseStorageClient {
        SupabaseClient.development.storage
    }
}
