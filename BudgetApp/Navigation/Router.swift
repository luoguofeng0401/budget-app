//
//  Router.swift
//  BudgetApp
//
//  Created by Guofeng Luo on 2026/8/19.
//

import Foundation
import Observation

enum Route {
    case login
    case budgets
}

@Observable
class Router {
    var routes: [Route] = []
}
