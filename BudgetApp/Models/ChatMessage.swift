//
//  ChatMessage.swift
//  BudgetApp
//
//  Created by Guofeng Luo on 2026/8/20.
//

import Foundation

struct ChatMessage: Codable, Identifiable, Equatable {
    var id: Int?
    var text: String
    var userId: UUID
    var email: String
    let createdAt: Date = Date()
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case text = "text"
        case userId = "user_id"
        case email = "email"
        case createdAt = "created_at"
    }
}
