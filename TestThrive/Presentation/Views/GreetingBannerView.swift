//
//  GreetingBannerView.swift
//  TestThrive
//
//  Created by Suwon An on 2026-09-17.
//

import SwiftUI

struct GreetingBannerView: View {
    
    let taskCount: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Hello Suwon,")
                .font(.subheadline)
                .foregroundColor(.secondary)
            HStack(spacing: 4) {
                Text("You have")
                Text("\(taskCount) tasks")
                    .bold()
                Text("to do")
            }
            .font(.title2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}
