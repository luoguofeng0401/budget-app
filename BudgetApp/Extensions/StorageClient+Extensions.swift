//
//  StorageClient+Extensions.swift
//  BudgetApp
//
//  Created by Guofeng Luo on 2026/8/21.
//

import Foundation
import Supabase

extension SupabaseStorageClient {
    
    func upload(data: Data, path: String, options: FileOptions) async throws -> String? {

        let response = try await self
            .from("receipts")
            .upload(
                path: path,
                file: data,
                options: options
            )

        return response.path

    }
}
