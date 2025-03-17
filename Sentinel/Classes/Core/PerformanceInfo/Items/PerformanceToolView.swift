//
//  PerformanceToolView.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 28.11.2024..
//

import SwiftUI

struct PerformanceToolView: View {

    @ObservedObject var viewModel: PerformanceInfoViewModel

    var body: some View {
        HStack(spacing: 10) {
            Text(viewModel.item.title)
                .font(.body2Bold)

            Text(viewModel.value)
                .font(.body2Regular)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .onAppear { viewModel.startTimer() }
    }
}
