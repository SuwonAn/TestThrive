//
//  APITaskRepository.swift
//  TestThrive
//
//  Created by Suwon An on 2026-09-17.
//

import Foundation


// MARK: - Network Repository Implementation


final class APITaskRepository: TaskRepositoryProtocol {
    
    private struct TodoDTO: Decodable {
        let userId: Int
        let id: Int
        let title: String
        let completed: Bool
    }

    func fetchPriorityTasks() async throws -> [TaskItem] {
        
        let todos = try await fetchTodos()
        let prioritized = Array(todos.filter { !$0.completed }.prefix(6))

        return prioritized.enumerated().map { index, todo in
            TaskItem(
                id: Self.taskID(for: todo.id),
                title: Self.makeDisplayTitle(from: todo.title),
                subtitle: Self.subtitle(for: todo.userId),
                iconName: Self.iconName(for: index, isCompleted: todo.completed),
                dueDate: Self.dateString(dayOffset: index + 1),
                isCompleted: todo.completed
            )
        }
    }

    func fetchTimelineTasks() async throws -> [GroupedTasks] {
        
        let todos = try await fetchTodos()
        let source = Array(todos.prefix(24))
        let groupSize = 4
        var groups: [GroupedTasks] = []

        for startIndex in stride(from: 0, to: source.count, by: groupSize) {
            let endIndex = min(startIndex + groupSize, source.count)
            let slice = source[startIndex..<endIndex]
            let dayOffset = startIndex / groupSize
            let headerDate = Calendar.current.date(byAdding: .day, value: -dayOffset, to: Date()) ?? Date()

            let tasks = slice.enumerated().map { offset, todo in
                TaskItem(
                    id: Self.taskID(for: todo.id),
                    title: Self.makeDisplayTitle(from: todo.title),
                    subtitle: Self.subtitle(for: todo.userId),
                    iconName: Self.iconName(for: startIndex + offset, isCompleted: todo.completed),
                    dueDate: nil,
                    isCompleted: todo.completed
                )
            }

            groups.append(
                GroupedTasks(
                    id: Self.groupID(for: slice.first?.id ?? startIndex),
                    dateHeader: "Added \(Self.dateString(from: headerDate))",
                    tasks: tasks
                )
            )
        }

        return groups
    }

    private func fetchTodos() async throws -> [TodoDTO] {
        
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/todos") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 15

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode([TodoDTO].self, from: data)
    }

    private static func subtitle(for userId: Int) -> String {
        
        let subtitles = [
            "Path to Wellness",
            "Daily Check",
            "Mindfulness Routine",
            "Growth Library",
            "Video Coaching",
            "Sleep Tracker"
        ]
        return subtitles[(max(userId, 1) - 1) % subtitles.count]
    }

    private static func taskID(for todoID: Int) -> UUID {
        // Produce a deterministic UUID from the integer id by embedding
        // a zero-padded 12-char hex suffix into the UUID string. Keep the
        // result stable across runs for the same `todoID`.
        let suffix = String(format: "%012x", UInt64(max(todoID, 0)))
        return UUID(uuidString: "00000000-0000-0000-0000-\(suffix)") ?? UUID()
    }

    private static func groupID(for sourceID: Int) -> UUID {
        
        let safeID = max(sourceID, 0)
        let suffix = String(format: "%012llx", UInt64(safeID + 1_000_000))
        return UUID(uuidString: "00000000-0000-0000-0001-\(suffix)") ?? UUID()
    }

    private static func iconName(for index: Int, isCompleted: Bool) -> String {
        
        if isCompleted { return "checkmark.circle.fill" }

        let icons = [
            "video.fill",
            "doc.text.fill",
            "book.fill",
            "heart.text.square.fill",
            "figure.mind.and.body",
            "calendar.badge.clock"
        ]
        return icons[index % icons.count]
    }

    private static func makeDisplayTitle(from rawTitle: String) -> String {
        
        guard let first = rawTitle.first else { return rawTitle }
        return first.uppercased() + rawTitle.dropFirst()
    }

    private static func dateString(dayOffset: Int) -> String {
        
        let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: Date()) ?? Date()
        return dateString(from: date)
    }

    private static func dateString(from date: Date) -> String {
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
}
