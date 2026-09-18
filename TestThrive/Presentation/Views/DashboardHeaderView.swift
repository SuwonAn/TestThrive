//
//  DashboardHeaderView.swift
//  TestThrive
//
//  Created by Suwon An on 2026-09-17.
//

import SwiftUI

// MARK: - Subviews

struct DashboardHeaderView: View {
    
    var body: some View {
        HStack {
            Image(systemName: "app.fill")
                .resizable()
                .frame(width: 36, height: 36)
                .foregroundColor(Color(red: 0.15, green: 0.25, blue: 0.45))
            Spacer()
            HStack(spacing: 16) {
                Button(action: {}) {
                    Image(systemName: "bell")
                        .foregroundColor(.primary)
                }
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.15))
                        .frame(width: 36, height: 36)
                    Text("PS")
                        .font(.system(size: 14, weight: .semibold))
                }
                Button(action: {}) {
                    Image(systemName: "ellipsis.vertical")
                        .foregroundColor(.primary)
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}
