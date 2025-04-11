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
                .font(.body1Bold)

            Text(viewModel.value)
                .font(.body1Regular)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .onAppear { viewModel.startTimer() }
    }
}
