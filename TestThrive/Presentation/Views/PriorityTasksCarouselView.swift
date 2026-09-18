//
//  PriorityTasksCarouselView.swift
//  TestThrive
//
//  Created by Suwon An on 2026-09-17.
//

import SwiftUI

/// Displays priority tasks in a horizontal carousel
/// Adapts card size based on available space and device (iPhone Duo support)
/// Follows iOS 27 responsive design principles
struct PriorityTasksCarouselView: View {
    
    let tasks: [TaskItem]
    // Use async handler to allow async/await flows from callers
    let onTaskTap: (TaskItem) async -> Void
    
    @Environment(\.layoutSize) var layoutSize
    @State private var cardHeight: CGFloat = 0
    
    private var displayedTasks: [TaskItem] {
        tasks
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Priority tasks")
                .font(.headline)
                .bold()
                .padding(.horizontal)

            // Always display horizontal carousel
            horizontalCarouselLayout
        }
    }
    
    struct HeightPreferenceKey: PreferenceKey {
        static var defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = max(value, nextValue())
        }
    }
    
    
    // MARK: - Horizontal Carousel (Preferred for regular width)
    
    private var horizontalCarouselLayout: some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                ForEach(displayedTasks) { task in
                    taskCard(task)
                        .background(
                            GeometryReader { geo in
                                Color.clear.preference(key: HeightPreferenceKey.self, value: geo.size.height)
                            }
                        )
                        .frame(width: cardWidth)
                }
            }
            .padding(.horizontal)
        }
        .onPreferenceChange(HeightPreferenceKey.self) { height in
            cardHeight = height
        }
        .frame(height: max(cardHeight, 70))
    }
    
    private var cardWidth: CGFloat {
        // Optimize card width based on available space
        // iPhone (390pt): 280pt cards → ~1.4 cards visible
        // iPhone Plus (430pt): 300pt cards → ~1.4 cards visible
        // iPhone Duo (340pt per screen): 260pt cards → ~1.3 per screen
        // iPad (600pt+): 310pt cards → 1.9+ cards visible
        
        let availableWidth = layoutSize.availableWidth
        
        // For hinged displays (iPhone Duo), use single screen width
        if layoutSize.hasHinge, let columnWidth = layoutSize.hingedColumnWidth {
            // Leave 20pt margin on each side for scrollview padding
            return columnWidth - 40
        }
        
        // Standard phones and tablets
        if availableWidth < 500 {
            // Small phones (iPhone SE, standard iPhone)
            return 280
        } else if availableWidth < 700 {
            // Larger phones (iPhone Plus, regular iPad height view)
            return 300
        } else {
            // Large tablets
            return 320
        }
    }
    
    // MARK: - Task Card Component
    /// Used in horizontal carousel layout
    /// Optimized for touch and visual hierarchy
    private func taskCard(_ task: TaskItem) -> some View {
        
        Button {
            Task {
                await onTaskTap(task)
            }
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                // Due date header
                if let dueDate = task.dueDate {
                    Text("Due \(dueDate)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                // Icon and title
                HStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.15))
                        .frame(width: 32, height: 32)
                        .overlay(Image(systemName: task.iconName).font(.system(size: 14))
                            .foregroundColor(.gray))

                    VStack(alignment: .leading, spacing: 1) {
                        Text(task.title)
                            .font(.system(size: 12, weight: .semibold))
                            .lineLimit(2)
                        HStack(spacing: 2) {
                            Image(systemName: "link")
                                .font(.caption2)
                            Text(task.subtitle)
                                .font(.caption2)
                        }
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    }

                    Spacer(minLength: 4)
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            .padding(8)
            .frame(maxHeight: .infinity, alignment: .topLeading)
            .background(Color(uiColor: .systemBackground))
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open \(task.title)")
    }
}
