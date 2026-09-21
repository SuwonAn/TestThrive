//
//  TimelineTasksSectionView.swift
//  TestThrive
//
//  Created by Suwon An on 2026-09-17.
//

import SwiftUI

struct TimelineTasksSectionView: View {
    
    let groups: [GroupedTasks]
    // Use an async handler so callers can use async/await instead of completion closures
    let onTaskTap: (TaskItem) async -> Void

    // Use the group's dateHeader as a stable key for expansion state.
    // Some data sources recreate GroupedTasks with new UUIDs on reload,
    // which would otherwise clear expansion if we keyed by UUID.
    @State private var isExpandedGroups: Set<String> = []
    @Binding var selectedSegment: Int
    
    private static let groupPageSize = 5
    // When collapsed, show this many tasks as a preview. Previously the
    // collapsed limit was `taskPageSize = 10` which meant groups with <= 10
    // tasks never appeared to collapse (you saw a blink but no change).
    // Set a small preview so collapse/expand is visible even for small groups.
    private static let collapsedPreviewSize = 2
    private static let taskPageSize = 10

    private var displayedGroups: [GroupedTasks] {
        Array(groups.prefix(Self.groupPageSize))
    }
    
    private var hasMoreGroups: Bool {
        groups.count > Self.groupPageSize
    }

    private func displayedTasks(for group: GroupedTasks) -> [TaskItem] {
        
        let isExpanded = isExpandedGroups.contains(group.dateHeader)
        let visibleCount = isExpanded ? group.tasks.count : min(Self.collapsedPreviewSize, group.tasks.count)
        return Array(group.tasks.prefix(visibleCount))
    }

    private func toggleGroupExpansion(for group: GroupedTasks) {
        
        let key = group.dateHeader
        if isExpandedGroups.contains(key) {
            isExpandedGroups.remove(key)
        } else {
            isExpandedGroups.insert(key)
        }
    }
    
    private func hasMoreTasksInGroup(_ group: GroupedTasks) -> Bool {
        group.tasks.count > Self.collapsedPreviewSize
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 20) {
                Button(action: { selectedSegment = 0 }) {
                    VStack(spacing: 4) {
                        Text("All tasks")
                            .font(.headline)
                            .foregroundColor(selectedSegment == 0 ? .primary : .secondary)
                        Rectangle()
                            .fill(selectedSegment == 0 ? Color.primary : Color.clear)
                            .frame(height: 2)
                    }
                }
                Button(action: { selectedSegment = 1 }) {
                    VStack(spacing: 4) {
                        Text("In Progress")
                            .font(.headline)
                            .foregroundColor(selectedSegment == 1 ? .primary : .secondary)
                        Rectangle()
                            .fill(selectedSegment == 1 ? Color.primary : Color.clear)
                            .frame(height: 2)
                    }
                }
                Button(action: { selectedSegment = 2 }) {
                    VStack(spacing: 4) {
                        Text("Completed")
                            .font(.headline)
                            .foregroundColor(selectedSegment == 2 ? .primary : .secondary)
                        Rectangle()
                            .fill(selectedSegment == 2 ? Color.primary : Color.clear)
                            .frame(height: 2)
                    }
                }
                Spacer()
            }
            .padding(.horizontal)
            
            LazyVStack(alignment: .leading, spacing: 0) {
                // Use explicit id to ensure SwiftUI can track each group uniquely
                ForEach(displayedGroups, id: \.id) { group in
                    HStack(alignment: .top, spacing: 12) {
                        VStack(spacing: 0) {
                            Circle()
                                .stroke(Color.gray, lineWidth: 3)
                                .background(Circle().fill(Color(uiColor: .systemGroupedBackground)))
                                .frame(width: 16, height: 16)
                                .padding(.top, 2)
                            Rectangle().fill(Color.red.opacity(0.4)).frame(width: 2)
                        }
                        
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text(group.dateHeader)
                                    .font(.caption)
                                    .bold()
                                    .foregroundColor(.secondary)
                                Spacer()
                                
                                if group.tasks.count > Self.collapsedPreviewSize {
                                    
                                    Button {
                                        // Animate expansion/collapse for better UX
                                        withAnimation {
                                            toggleGroupExpansion(for: group)
                                        }
                                    } label: {
                                        Image(systemName: isExpandedGroups.contains(group.dateHeader) ? "chevron.up" : "chevron.down")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                            }
                            // Compute expansion local flag so we can give the tasks
                            // container a distinct identity when expanded vs collapsed.
                            let isExpanded = isExpandedGroups.contains(group.dateHeader)
                            let tasks = displayedTasks(for: group)
                            VStack(spacing: 1) {
                                
                                ForEach(Array(tasks.enumerated()), id: \.element.id) { index, task in
                                    Button {
                                        Task {
                                            await onTaskTap(task)
                                        }
                                    } label: {
                                        HStack(spacing: 12) {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color.gray.opacity(0.12))
                                                .frame(width: 40, height: 40)
                                                .overlay(Image(systemName: task.iconName).foregroundColor(.primary))
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(task.title)
                                                    .font(.system(size: 14, weight: .bold))
                                                HStack(spacing: 4) {
                                                    Image(systemName: "link").font(.caption2)
                                                    Text(task.subtitle).font(.caption)
                                                }
                                                .foregroundColor(.secondary)
                                            }
                                            Spacer()
                                            Image(systemName: "chevron.right").font(.caption).foregroundColor(.gray)
                                        }
                                        .padding(12)
                                        .background(Color(uiColor: .systemBackground))
                                    }
                                    .buttonStyle(.plain)
                                    .accessibilityLabel("Open \(task.title)")
                                    
                                    if index < tasks.count - 1 {
                                        Divider().padding(.leading, 12)
                                    }
                                }
                            }
                            // Force SwiftUI to recreate the tasks container when the
                            // expanded state or visible count changes. This avoids a
                            // case where the chevron image updates but the task
                            // list doesn't because the inner view didn't receive a
                            // meaningful identity change.
                            .id(isExpanded ? "expanded-\(group.dateHeader)-\(tasks.count)" : "collapsed-\(group.dateHeader)-\(tasks.count)")
                            .cornerRadius(12)
                            .padding(.bottom, 20)
                        }
                        // Removed explicit .id here — ForEach already provides a
                        // stable identity via `id: \.id`. Avoid adding extra ids
                        // on child containers that can interfere with diffing.
                    }
                    .onAppear {
                        // Reset state when group appears or changes
                    }
                }
            }
            .padding(.horizontal)
        }
        .onAppear {
            isExpandedGroups = []
        }
        .onChange(of: groups.map(\.id)) { _, _ in
            isExpandedGroups = []
        }
        .onChange(of: selectedSegment) { _, _ in
            isExpandedGroups = []
        }
    }
}
