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
    
    @State private var router = Router()
    let authClient: AuthClient = .development
    let storageClient: SupabaseStorageClient = .development
    @State private var signInStatus: SignInStatus = .idle
    // Keep a single store instance for the app's lifetime. Creating it inline
    // in `body` would rebuild it (and the whole environment tree) on every
    // Scene re-evaluation, tearing down presented sheets.
    @State private var store = ExpenseTrackerStore(supabaseClient: .development)
    
    private enum SignInStatus {
        case idle
        case signedIn
        case signedOut
    }
    
    private func listenAuthEvents() async {

        for await (event, _) in authClient.authStateChanges {
            if case .initialSession = event {
                do {
                    let _ = try await authClient.session
                    signInStatus = .signedIn
                } catch let error as AuthError {
                    print(error)
                    signInStatus = .signedOut
                } catch {
                    signInStatus = .signedOut
                }
            }
            
            if case .signedIn = event {
                router.routes.append(.budgets)
                signInStatus = .signedIn
            } else if case .signedOut = event {
                router.routes = []
                signInStatus = .signedOut
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.routes) {
                
                Group {
                    switch signInStatus {
                    case .idle:
                        ProgressView("Laoding...")
                    case .signedIn:
                        BudgetListScreen()
                    case .signedOut:
                        LoginScreen()
                    }
                }
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .budgets:
                        BudgetListScreen()
                    case .login:
                        LoginScreen()
                    }
                }
            }
            .environment(store)
            .environment(\.authClient, .development)
            .environment(\.storageClient, storageClient)
            .environment(router)
            .task {
                await listenAuthEvents()
            }
        }
    }
}
