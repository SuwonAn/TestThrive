//
//  GroupedTasks.swift
//  TestThrive
//
//  Created by Suwon An on 2026-09-17.
//

import Foundation

// MARK: - Entities

struct GroupedTasks: Identifiable, Sendable {
    let id: UUID
    let dateHeader: String
    let tasks: [TaskItem]
}
