//
//  BudgetAppApp.swift
//  BudgetApp
//
//  Created by Guofeng Luo on 2026/8/17.
//

import SwiftUI
import Supabase

@main
struct BudgetAppApp: App {

    @State private var store: ExpenseTrackerStore

    init() {
        _store = State(initialValue: ExpenseTrackerStore(supabaseClient: .development))
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                BudgetListScreen()
            }
            .environment(store)
        }
    }
}
