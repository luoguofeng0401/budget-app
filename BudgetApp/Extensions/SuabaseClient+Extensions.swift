//
//  SuabaseClient+Extensions.swift
//  BudgetApp
//
//  Created by Guofeng Luo on 2026/8/17.
//

import Foundation
import Supabase

extension SupabaseClient {
    
    static let development = SupabaseClient(supabaseURL: URL(string: "https://dwmdrucejwsdtqfaqtmc.supabase.co")!, supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR3bWRydWNlandzZHRxZmFxdG1jIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODY5Mjc4NDcsImV4cCI6MjEwMjUwMzg0N30.4UuouiG7RCtvWf8Pt2efD-duXTP6mU3Pgx1WaXsJuKA")
}
