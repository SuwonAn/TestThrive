//
//  MockTaskRepository.swift
//  TestThrive
//
//  Created by Suwon An on 2026-09-17.
//

import Foundation

/// Mock repository for Preview only
/// In production, use APITaskRepository instead
final class MockTaskRepository: TaskRepositoryProtocol {
    
    func fetchPriorityTasks() async throws -> [TaskItem] {
        
        return [
            TaskItem(id: UUID(), title: "Task 1", subtitle: "Subtitle", iconName: "star.fill", dueDate: "Today", isCompleted: false),
            TaskItem(id: UUID(), title: "Task 2", subtitle: "Subtitle", iconName: "checkmark.circle.fill", dueDate: "Tomorrow", isCompleted: false)
        ]
    }
    
    func fetchTimelineTasks() async throws -> [GroupedTasks] {
        
        return [
            GroupedTasks(id: UUID(), dateHeader: "Today", tasks: [
                TaskItem(id: UUID(), title: "Task 1", subtitle: "Subtitle", iconName: "star.fill", dueDate: nil, isCompleted: false),
                TaskItem(id: UUID(), title: "Task 2", subtitle: "Subtitle", iconName: "checkmark.circle.fill", dueDate: nil, isCompleted: true)
            ])
        ]
    }
    
}
