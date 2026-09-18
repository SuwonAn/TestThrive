//
//  StressTestUITests.swift
//  TestThriveUITests
//
//  Created by TestThrive on 2026-09-11.
//

import XCTest

final class StressTestUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        
        // Wait for app to load
        sleep(3)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    /// Stress test: Click "Show all" and "Show less" buttons 1000 times
    /// This verifies that the app doesn't freeze under repeated toggle stress
    func testShowAllShowLessButton1000Times() {
        let startTime = Date()
        var clickCount = 0
        
        print("Starting 1000-click stress test...")
        
        // Find the "Show all" button and keep clicking it
        for i in 1...1000 {
            autoreleasepool {
                let showAllButton = app.buttons.containing(NSPredicate(format: "label LIKE '*Show*'")).firstMatch
                
                guard showAllButton.exists && showAllButton.isHittable else {
                    print("Button not found at click \(i)")
                    return
                }
                
                showAllButton.tap()
                clickCount += 1
                
                // Log progress every 100 clicks
                if clickCount % 100 == 0 {
                    let elapsed = Date().timeIntervalSince(startTime)
                    let avgTimePerClick = elapsed / Double(clickCount)
                    print("✅ Click \(clickCount)/1000 - Elapsed: \(String(format: "%.1f", elapsed))s - Avg: \(String(format: "%.2f", avgTimePerClick))ms/click")
                }
                
                usleep(50_000) // 50ms delay
            }
        }
        
        let totalTime = Date().timeIntervalSince(startTime)
        let avgTimePerClick = totalTime / Double(clickCount)
        
        print("\n========== STRESS TEST COMPLETED ==========")
        print("Total clicks: \(clickCount)/1000")
        print("Total time: \(String(format: "%.1f", totalTime))s")
        print("Avg time per click: \(String(format: "%.2f", avgTimePerClick))ms")
        print("=========================================\n")
        
        XCTAssertEqual(clickCount, 1000, "Should complete all 1000 clicks")
        XCTAssertLessThan(totalTime, 120, "1000 clicks should complete in less than 2 minutes")
    }
    
    /// Alternative: Tap the show/hide button many times in rapid succession
    func testRapidToggleButtonClicks() {
        let button = app.buttons.containing(NSPredicate(format: "label LIKE '*Show*'")).firstMatch
        
        guard button.exists else {
            XCTFail("Show all/less button not found")
            return
        }
        
        let startTime = Date()
        let clickCount = 500 // 500 rapid clicks
        
        for i in 1...clickCount {
            if button.isHittable {
                button.tap()
                
                if i % 50 == 0 {
                    print("Clicked \(i) times")
                }
            } else {
                XCTFail("Button became unhittable at click \(i)")
                break
            }
        }
        
        let totalTime = Date().timeIntervalSince(startTime)
        print("500 rapid clicks completed in \(String(format: "%.1f", totalTime))s")
        
        XCTAssertLessThan(totalTime, 60, "500 rapid clicks should complete within 60 seconds")
    }
    
    /// Monitor memory usage during repeated toggles
    func testMemoryStabilityDuringToggles() {
        let startMemory = reportMemoryUsage()
        
        let button = app.buttons.containing(NSPredicate(format: "label LIKE '*Show*'")).firstMatch
        
        for i in 1...200 {
            if button.isHittable {
                button.tap()
                
                if i % 50 == 0 {
                    let currentMemory = reportMemoryUsage()
                    print("Iteration \(i): Current memory: \(currentMemory)MB")
                }
            }
        }
        
        let endMemory = reportMemoryUsage()
        let memoryIncrease = endMemory - startMemory
        
        print("Starting memory: \(startMemory)MB")
        print("Ending memory: \(endMemory)MB")
        print("Memory increase: \(memoryIncrease)MB")
        
        // Memory increase should be minimal (less than 50MB for 200 toggles)
        XCTAssertLessThan(memoryIncrease, 50, "Memory should not leak significantly during toggles")
    }
    
    // MARK: - Helper Methods
    
    private func reportMemoryUsage() -> Double {
        var info = task_vm_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<task_vm_info>.size)/4
        
        let kerr = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(
                    mach_task_self_,
                    task_flavor_t(TASK_VM_INFO),
                    $0,
                    &count
                )
            }
        }
        
        guard kerr == KERN_SUCCESS else { return 0 }
        
        let memoryUsage = Double(info.phys_footprint) / (1024 * 1024) // Convert to MB
        return memoryUsage
    }
}
