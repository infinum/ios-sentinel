//
//  SentinelListView.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 08.11.2024..
//

import SwiftUI

struct SentinelListView: View {

    let toolTable: ToolTable

    var body: some View {
        LazyVStack {
            ForEach(toolTable.sections, id: \.title) { section in
                Section(section.title ?? "") {
                    section.
                }
            }
        }
    }
}

#Preview {
    SentinelListView()
}
