//
//  DualScreenEnvironment.swift
//  TestThrive
//
//  Created by Suwon An on 2026-09-16.
//

import SwiftUI

// MARK: - Responsive Layout Information
/// Provides information about available space for responsive layout decisions.
/// Following iOS 27 principles: design for available space, not device model.
struct LayoutSizeInfo: Equatable {
    /// Total available width (window, window in Mirroring, or split view)
    let availableWidth: CGFloat
    
    /// Total available height
    let availableHeight: CGFloat
    
    /// Estimated hinge position (nil if no hinge or single screen)
    let hingePosition: CGFloat?
    
    /// Whether layout should adapt to hinged/split screen behavior
    var hasHinge: Bool { hingePosition != nil }
    
    /// Minimum useful width threshold
    /// Below this, single-column layouts required
    private let narrowThreshold: CGFloat = 540
    
    /// Medium width threshold
    /// Above this, can consider two-column layouts
    private let mediumThreshold: CGFloat = 800
    
    /// Wide width threshold
    /// Above this, can use expanded sidebars and persistent elements
    private let wideThreshold: CGFloat = 1200
    
    enum LayoutClass {
        /// Very narrow: single column essential
        case narrow
        /// Medium: two columns possible but not required
        case medium
        /// Wide: persistent sidebars viable
        case wide
    }
    
    /// Current layout class based on available space
    var layoutClass: LayoutClass {
        if availableWidth < mediumThreshold {
            return .narrow
        } else if availableWidth < wideThreshold {
            return .medium
        } else {
            return .wide
        }
    }
    
    /// Space available for one "column" with hinge
    var hingedColumnWidth: CGFloat? {
        guard hingePosition != nil else { return nil }
        // Assume hinge width ~26pt
        let hingeWidth: CGFloat = 26
        return (availableWidth - hingeWidth) / 2
    }
}

// MARK: - Environment Key
struct LayoutSizeEnvironmentKey: EnvironmentKey {
    static let defaultValue = LayoutSizeInfo(
        availableWidth: 390,
        availableHeight: 844,
        hingePosition: nil
    )
}

extension EnvironmentValues {
    var layoutSize: LayoutSizeInfo {
        get { self[LayoutSizeEnvironmentKey.self] }
        set { self[LayoutSizeEnvironmentKey.self] = newValue }
    }
}

// MARK: - Layout Size Provider Modifier
/// Detects available space and hinge position, updates environment
struct LayoutSizeModifier: ViewModifier {
    @State private var  layoutSize: LayoutSizeInfo = LayoutSizeEnvironmentKey.defaultValue
    
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            let size = geometry.size
            
            // Detect hinge: if aspect ratio suggests hinged display (~680w x ~540h)
            // and width falls in dual-screen range, estimate hinge at center
            let estimatedHinge: CGFloat? = detectHinge(width: size.width, height: size.height)
            
            let layoutInfo = LayoutSizeInfo(
                availableWidth: size.width,
                availableHeight: size.height,
                hingePosition: estimatedHinge
            )
            
            content
                .environment(\.layoutSize, layoutInfo)
                .onAppear {
                    layoutSize = layoutInfo
                }
                .onChange(of: geometry.size) { _, newSize in
                    layoutSize = LayoutSizeInfo(
                        availableWidth: newSize.width,
                        availableHeight: newSize.height,
                        hingePosition: detectHinge(width: newSize.width, height: newSize.height)
                    )
                }
        }
    }
    
    /// Detects hinge position based on device dimensions
    /// This is heuristic-based; real devices may report hinge differently
    private func detectHinge(width: CGFloat, height: CGFloat) -> CGFloat? {
        // iPhone Duo characteristics: ~680w x ~540h, with hinge ~26pt wide at center
        // Only report hinge if dimensions suggest dual-screen device
        let isDualScreenRatio = width > 600 && width < 750 && height > 450 && height < 600
        
        guard isDualScreenRatio else { return nil }
        
        // Hinge at approximate center
        return width / 2
    }
}

extension View {
    /// Apply responsive layout detection based on available space
    func applyResponsiveLayout() -> some View {
        modifier(LayoutSizeModifier())
    }
}
