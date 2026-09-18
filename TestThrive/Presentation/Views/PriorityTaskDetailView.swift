//
//  PriorityTaskDetailView.swift
//  TestThrive
//
//  Created by Suwon An on 2026-09-17.
//

import SwiftUI

struct PriorityTaskDetailView: View {
    
    let task: TaskItem
    @EnvironmentObject var viewModel: TaskDashboardViewModel
    @State private var isCompleted: Bool

    init(task: TaskItem) {
        self.task = task
        _isCompleted = State(initialValue: task.isCompleted)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.15))
                        .frame(width: 54, height: 54)
                        .overlay(Image(systemName: task.iconName)
                            .foregroundColor(.gray))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(task.title)
                            .font(.title3)
                            .bold()
                        Text(task.subtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                if let dueDate = task.dueDate {
                    Label("Due \(dueDate)", systemImage: "calendar")
                        .font(.subheadline)
                }

                Label(isCompleted ? "Completed" : "In progress",
                      systemImage: isCompleted ? "checkmark.circle.fill" : "clock")
                    .font(.subheadline)
                    .foregroundColor(isCompleted ? .green : .orange)

                Button {
                    withAnimation {
                        isCompleted.toggle()
                        // call view model async update without blocking UI
                        Task {
                            await viewModel.setTaskCompletion(taskID: task.id, isCompleted: isCompleted)
                        }
                    }
                } label: {
                    Label(isCompleted ? "Mark as In Progress" : "Mark as Completed",
                          systemImage: isCompleted ? "arrow.uturn.backward.circle.fill" : "checkmark.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    // Placeholder action: connect to task workflow when backend/state is ready.
                } label: {
                    Label(isCompleted ? "Review Task" : (task.dueDate == nil ? "Start Task" : "Continue Task"),
                          systemImage: isCompleted ? "eye.fill" : "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Spacer(minLength: 0)
            }
            .padding()
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Task Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
            PriorityTaskDetailView(
                    task: TaskItem(
                        id: UUID(),
                        title: "Watch 5 steps to relaxation",
                        subtitle: "Path to Wellness",
                        iconName: "video.fill",
                        dueDate: "Jun 8, 2023",
                        isCompleted: false
                    )
                )
                .environmentObject(TaskDashboardViewModel(fetchTasksUseCase: FetchTasksUseCase(repository: MockTaskRepository())))
    }
}
