//
//  AuthClientKey .swift
//  BudgetApp
//
//  Created by Guofeng Luo on 2026/8/18.
//

import Foundation
import SwiftUI
import Supabase

struct AuthClientKey: EnvironmentKey {
    
    static var defaultValue: AuthClient = SupabaseClient.development.auth
}

extension EnvironmentValues {
     
    var authClient: AuthClient {
        get { self[AuthClientKey.self] }
        set { self[AuthClientKey.self] = newValue  }
    }
}
