//
//  NavigationToolTableView.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 27.11.2024..
//

import SwiftUI

struct NavigationToolTableView: View {

    let title: String
    #if os(macOS)
    let didSelect: (Binding<String?>) -> any View
    #else
    let didSelect: () -> any View
    #endif

    var body: some View {
        HStack(spacing: 10) {
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

}

// MARK: - Helpers

extension NavigationToolTableView {

    init(item: NavigationToolItem) {
        title = item.title
        didSelect = item.didSelect
    }
}
