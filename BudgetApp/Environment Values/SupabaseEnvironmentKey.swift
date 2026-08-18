//
//  SupabaseEnvironmentKey.swift
//  BudgetApp
//
//  Created by Guofeng Luo on 2026/8/17.
//

import Foundation
import SwiftUI
import Supabase

struct SupabaseEnvironmentKey: EnvironmentKey {
    static var defaultValue: SupabaseClient = .development
}

extension EnvironmentValues {
    var supabaseClient: SupabaseClient {
        get { self[SupabaseEnvironmentKey.self] }
        set { self[SupabaseEnvironmentKey.self] = newValue }
    }
}
