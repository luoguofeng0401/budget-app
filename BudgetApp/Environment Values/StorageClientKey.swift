//
//  StorageClientKey.swift
//  BudgetApp
//
//  Created by Guofeng Luo on 2026/8/19.
//

import Foundation
import SwiftUI
import Supabase

struct StorageKey: EnvironmentKey {
    static var defaultValue: SupabaseStorageClient = SupabaseClient.development.storage
}

extension EnvironmentValues {
    var storageClient: SupabaseStorageClient {
        get { self[StorageKey.self] }
        set { self[StorageKey.self] = newValue }
    }
}
