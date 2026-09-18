//
//  TaskDashboardViewModel.swift
//  TestThrive
//
//  Created by Suwon An on 2026-09-17.
//

import SwiftUI
internal import Combine

@MainActor
final class AppCoordinator: ObservableObject {
    
    @Published var selectedTab: AppTab = .home
    @Published var homePath: [AppRoute] = []

    func selectTab(_ tab: AppTab) {
        selectedTab = tab
    }

    func openTaskDetail(_ task: TaskItem) {
        selectedTab = .home
        homePath.append(.taskDetail(task))
    }
}
