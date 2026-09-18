//
//  DualScreenDashboardView.swift
//  TestThrive
//
//  Created by Suwon An on 2026-09-17.
//

import SwiftUI

/// Responsive dashboard that adapts to available space.
/// Follows iOS 27 principles: respond to available space, not device model.
struct DualScreenDashboardView: View {
    
    @ObservedObject var viewModel: TaskDashboardViewModel
    @ObservedObject var coordinator: AppCoordinator
    @Environment(\.layoutSize) var layoutSize
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    var body: some View {
        NavigationStack(path: $coordinator.homePath) {
            adaptiveLayout
        }
    }

    
    // MARK: - Responsive Layout Based on Available Space
    
    
    @ViewBuilder
    private var adaptiveLayout: some View {
        
        switch layoutSize.layoutClass {
        case .narrow:
            // Single-column: everything stacks vertically
            singleColumnLayout
            
        case .medium:
            // Can use two columns, but not forced
            twoColumnLayout
            
        case .wide:
            // Wide enough for persistent elements
            twoColumnLayout
        }
    }

    
    // MARK: - Single Column Layout
    /// Used when width < 800 points
    /// Prioritizes readability and touch targets

    private var singleColumnLayout: some View {
        
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 20) {
                DashboardHeaderView()
                GreetingBannerView(taskCount: viewModel.totalTaskCount)
                
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 40)
                } else {
                    PriorityTasksCarouselView(
                        tasks: viewModel.priorityTasks,
                        onTaskTap: { task in
                            // ensure navigation happens on main actor
                            await MainActor.run { coordinator.openTaskDetail(task) }
                        }
                    )
                    TimelineTasksSectionView(
                        groups: viewModel.filteredTaskGroups,
                        onTaskTap: { task in
                            await MainActor.run { coordinator.openTaskDetail(task) }
                        },
                        selectedSegment: $viewModel.selectedSegment
                    )
                }
                }
                  .padding(.bottom, 20)
                }
                .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
                .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(for: AppRoute.self) { route in
            switch route {
            case let .taskDetail(task):
                PriorityTaskDetailView(task: task)
                    .environmentObject(viewModel)
            }
        }
    }

    // MARK: - Two Column Layout
    /// Used when width >= 800 points
    /// Utilizes horizontal space efficiently
    /// Adapts to hinged displays (e.g., iPhone Duo)
    private var twoColumnLayout: some View {
        
        let hingeWidth: CGFloat = layoutSize.hasHinge ? 26 : 0
        let columnSpacing = layoutSize.hasHinge ? hingeWidth : 20
        
        return HStack(spacing: columnSpacing) {
            // Left column
            VStack(spacing: 20) {
                DashboardHeaderView()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        GreetingBannerView(taskCount: viewModel.totalTaskCount)
                        
                        if viewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 40)
                        } else {
                            PriorityTasksCarouselView(
                                tasks: viewModel.priorityTasks,
                                onTaskTap: { task in
                                    await MainActor.run { coordinator.openTaskDetail(task) }
                                }
                            )
                        }
                    }
                    .padding(.bottom, 20)
                }
                .background(Color(uiColor: .systemGroupedBackground))
            }
            // Constrain column width using containerRelativeFrame
            // This adapts to actual available space, not hardcoded values
            .containerRelativeFrame(.horizontal, count: 2, span: 1, spacing: columnSpacing)
            
            // Right column
            VStack(spacing: 0) {
                HStack {
                    Text("Timeline")
                        .font(.headline)
                        .bold()
                    Spacer()
                }
                .padding()
                
                ScrollView(.vertical, showsIndicators: false) {
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 40)
                    } else {
                        TimelineTasksSectionView(
                            groups: viewModel.filteredTaskGroups,
                            onTaskTap: { task in
                                await MainActor.run { coordinator.openTaskDetail(task) }
                            },
                            selectedSegment: $viewModel.selectedSegment
                        )
                    }
                }
                .background(Color(uiColor: .systemGroupedBackground))
            }
            .containerRelativeFrame(.horizontal, count: 2, span: 1, spacing: columnSpacing)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(for: AppRoute.self) { route in
            switch route {
            case let .taskDetail(task):
                PriorityTaskDetailView(task: task)
                    .environmentObject(viewModel)
            }
        }
    }
}

#Preview {
    DualScreenDashboardView(
        viewModel: TaskDashboardViewModel(
            fetchTasksUseCase: FetchTasksUseCase(repository: MockTaskRepository())
        ),
        coordinator: AppCoordinator()
    )
    .applyResponsiveLayout()
}
