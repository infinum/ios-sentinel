//
//  UserDefaultsToolView.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 21.01.2025..
//

import SwiftUI

struct UserDefaultsToolView: View {

    @ObservedObject var viewModel: UserDefaultsToolViewModel

    var body: some View {
        SentinelListView(title: viewModel.name, items: viewModel.sections)
            .onAppear {
                viewModel.updateSections()
            }
    }
}
