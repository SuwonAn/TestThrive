//
//  TaskDashboardViewModel.swift
//  TestThrive
//
//  Created by Suwon An on 2026-09-17.
//

import Foundation
internal import Combine

@MainActor
final class TaskDashboardViewModel: ObservableObject {
    
    // State
    @Published private(set) var hasLoadedInitialData: Bool = false
    @Published private(set) var priorityTasks: [TaskItem] = []
    @Published private(set) var timelineTaskGroups: [GroupedTasks] = []
    @Published private(set) var totalTaskCount: Int = 0
    @Published private(set) var isLoading: Bool = false
    // 0: All tasks, 1: In Progress, 2: Completed
    @Published var selectedSegment: Int = 0
    
    // Prevent concurrent update tasks
    private var isUpdating: Bool = false
    
    // Computed property: filter on-demand without publishing
    var filteredTaskGroups: [GroupedTasks] {
        
        switch selectedSegment {
        case 1: // In Progress
            return timelineTaskGroups.compactMap { group in
                let inProgressTasks = group.tasks.filter { !$0.isCompleted }
                return inProgressTasks.isEmpty ? nil : GroupedTasks(id: group.id, dateHeader: group.dateHeader, tasks: inProgressTasks)
            }
            
        case 2: // Completed
            return timelineTaskGroups.compactMap { group in
                let completedTasks = group.tasks.filter { $0.isCompleted }
                return completedTasks.isEmpty ? nil : GroupedTasks(id: group.id, dateHeader: group.dateHeader, tasks: completedTasks)
            }
            
        default: // 0: All tasks
            return timelineTaskGroups
        }
    }
    
    // Dependencies
    private let fetchTasksUseCase: FetchTasksUseCaseProtocol
    
    init(fetchTasksUseCase: FetchTasksUseCaseProtocol) {
        self.fetchTasksUseCase = fetchTasksUseCase
    }
    
    func loadDashboardData(forceReload: Bool = false) async {
        
        if isLoading { return }
        if hasLoadedInitialData && !forceReload { return }

        isLoading = true
        defer { isLoading = false }
        
        do {
            async let priorityResult = fetchTasksUseCase.executePriority()
            async let timelineResult = fetchTasksUseCase.executeTimeline()
            
            let (priority, timeline) = try await (priorityResult, timelineResult)
            self.priorityTasks = priority
            self.timelineTaskGroups = timeline
            
            rebuildDerivedState()
            self.hasLoadedInitialData = true
        } catch {
            // Error Handling (Alert state update)
            print("Failed to load dashboard data: \(error)")
            self.hasLoadedInitialData = true
        }
    }

    // Rename to `setTaskCompletion` to avoid confusion with completion-handler terminology.
    func setTaskCompletion(taskID: UUID, isCompleted: Bool) async {
        // Prevent concurrent updates
        guard !isUpdating else { return }
        isUpdating = true
        defer { isUpdating = false }

        // Small delay to allow UI to respond
        try? await Task.sleep(nanoseconds: 1_000_000) // 1ms

        // Update timeline groups
        let updatedTimelineGroups = self.timelineTaskGroups.map { group in
            let updatedTasks = group.tasks.map { task in
                guard task.id == taskID else { return task }
                return TaskItem(
                    id: task.id,
                    title: task.title,
                    subtitle: task.subtitle,
                    iconName: task.iconName,
                    dueDate: task.dueDate,
                    isCompleted: isCompleted
                )
            }
            return GroupedTasks(id: group.id, dateHeader: group.dateHeader, tasks: updatedTasks)
        }

        // Update priority tasks
        let updatedPriorityTasks = self.priorityTasks.map { task in
            guard task.id == taskID else { return task }
            return TaskItem(
                id: task.id,
                title: task.title,
                subtitle: task.subtitle,
                iconName: task.iconName,
                dueDate: task.dueDate,
                isCompleted: isCompleted
            )
        }

        // Update state (class is @MainActor so this runs on main actor)
        self.timelineTaskGroups = updatedTimelineGroups
        self.priorityTasks = updatedPriorityTasks
    }

    private func rebuildDerivedState() {
        // Keep expensive list transformations out of SwiftUI body recomputation.
        totalTaskCount = priorityTasks.count + timelineTaskGroups.flatMap { $0.tasks }.count
        // Note: filteredTaskGroups is now a computed property, no need to rebuild
    }
}
