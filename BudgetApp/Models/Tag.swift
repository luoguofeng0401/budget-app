//
//  Tag.swift
//  BudgetApp
//
//  Created by Guofeng Luo on 2026/8/21.
//

import Foundation

struct Tag: Codable, Identifiable, Hashable {
    var id: Int?
    let name: String
}
