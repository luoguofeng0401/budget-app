//
//  SettingsScreen.swift
//  BudgetApp
//
//  Created by Guofeng Luo on 2026/8/19.
//

import SwiftUI
import Auth

struct SettingsScreen: View {
    
    @Environment(\.authClient) private var authClient
    
    var body: some View {
        Button("Sign Out") {
            Task {
                do {
                    try await authClient.signOut()
                } catch {
                    print(error)
                }
            }
        }
    }
}

#Preview {
    SettingsScreen()
        .environment(\.authClient, .development)
}
