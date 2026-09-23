//
//  TestThriveApp.swift
//  TestThrive
//
//  Created by Suwon An on 2026-09-17.
//

import SwiftUI

@main
struct TestThriveApp: App {
    
    @StateObject private var viewModel: TaskDashboardViewModel
    @StateObject private var coordinator = AppCoordinator()
    @State private var selectedTabLocal: AppTab = .home

    init() {
        // DI Container / Composition Root Assembly
//        let repository = MockTaskRepository()
        let repository = APITaskRepository()
        let useCase = FetchTasksUseCase(repository: repository)
        _viewModel = StateObject(wrappedValue: TaskDashboardViewModel(fetchTasksUseCase: useCase))
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if viewModel.hasLoadedInitialData {
                    TabView(selection: $selectedTabLocal) {
                        // Home Tab with Responsive Layout (adapts to any width, including dual-screen)
                        DualScreenDashboardView(viewModel: viewModel, coordinator: coordinator)
                            .tabItem { Label("Home", systemImage: "house.fill") }
                            .tag(AppTab.home)

                        Text("Your Care")
                            .tabItem { Label("Your Care", systemImage: "building.2.fill") }
                            .tag(AppTab.yourCare)

                        Text("Discover")
                            .tabItem { Label("Discover", systemImage: "book.fill") }
                            .tag(AppTab.discover)

                        Text("Health Profile")
                            .tabItem { Label("Health Profile", systemImage: "person.text.rectangle.fill") }
                            .tag(AppTab.healthProfile)
                    }
                    .tint(Color(red: 0.15, green: 0.25, blue: 0.45))
                    // Keep coordinator and local selection in sync without
                    // binding across actor boundaries.
                    .onAppear {
                        // initialize local selection from coordinator (MainActor)
                        Task { @MainActor in
                            selectedTabLocal = coordinator.selectedTab
                        }
                    }
                    .onChange(of: selectedTabLocal) {
                        // propagate local changes back to coordinator on MainActor
                        Task { @MainActor in
                            coordinator.selectTab(selectedTabLocal)
                        }
                    }
                    .onReceive(coordinator.$selectedTab) { new in
                        // keep local state in-sync when coordinator changes
                        Task { @MainActor in
                            selectedTabLocal = new
                        }
                    }
                } else {
                    VStack(spacing: 12) {
                        ProgressView()
                            .controlSize(.large)
                        Text("Loading...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
                }
            }
            .applyResponsiveLayout()
            .task {
                await viewModel.loadDashboardData()
            }
        }
    }
}
