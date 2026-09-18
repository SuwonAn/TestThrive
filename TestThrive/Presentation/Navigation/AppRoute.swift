//
//  TaskDashboardViewModel.swift
//  TestThrive
//
//  Created by Suwon An on 2026-09-17.
//

import Foundation

/// Represents all app-level destinations managed by the coordinator.
enum AppRoute: Hashable {
    case taskDetail(TaskItem)
}

enum AppTab: Hashable {
    case home
    case yourCare
    case discover
    case healthProfile

    var deepLinkToken: String {
        switch self {
        case .home:
            return "home"
        case .yourCare:
            return "your-care"
        case .discover:
            return "discover"
        case .healthProfile:
            return "health-profile"
        }
    }

    static func fromDeepLinkToken(_ token: String) -> AppTab? {
        
        switch token.lowercased() {
        case "home":
            return .home
        case "your-care", "yourcare":
            return .yourCare
        case "discover":
            return .discover
        case "health-profile", "healthprofile":
            return .healthProfile
        default:
            return nil
        }
    }
}
