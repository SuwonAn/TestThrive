//
//  TaskItem.swift
//  TestThrive
//
//  Created by Suwon An on 2026-09-17.
//

import Foundation

// MARK: - Entities
struct TaskItem: Identifiable, Hashable, Sendable {
    let id: UUID
    let title: String
    let subtitle: String
    let iconName: String
    let dueDate: String?
    let isCompleted: Bool
}
