//
//  TaskRepositoryProtocol.swift
//  TestThrive
//
//  Created by Suwon An on 2026-09-17.
//

import Foundation

protocol TaskRepositoryProtocol: Sendable {
    func fetchPriorityTasks() async throws -> [TaskItem]
    func fetchTimelineTasks() async throws -> [GroupedTasks]
}
