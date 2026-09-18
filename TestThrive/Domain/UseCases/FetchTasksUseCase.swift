//
//  FetchTasksUseCase.swift
//  TestThrive
//
//  Created by Suwon An on 2026-09-17.
//

import Foundation

// MARK: - Use Cases
protocol FetchTasksUseCaseProtocol: Sendable {
    func executePriority() async throws -> [TaskItem]
    func executeTimeline() async throws -> [GroupedTasks]
}

final class FetchTasksUseCase: FetchTasksUseCaseProtocol {
    
    private let repository: TaskRepositoryProtocol
    
    init(repository: TaskRepositoryProtocol) {
        self.repository = repository
    }
    
    func executePriority() async throws -> [TaskItem] {
        try await repository.fetchPriorityTasks()
    }
    
    func executeTimeline() async throws -> [GroupedTasks] {
        try await repository.fetchTimelineTasks()
    }
}
