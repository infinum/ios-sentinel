//
//  NavigationToolTableView.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 27.11.2024..
//

import SwiftUI

struct NavigationToolTableView: View {

    let title: String
    let value: String?
    #if os(macOS)
    /// Binding is provided from the parent screen, which should be set to nil if we want to navigate the user back once they perform an action
    let didSelect: (Binding<String?>) -> any View
    #else
    let didSelect: () -> any View
    #endif

    var body: some View {
        VStack(spacing: 10) {
            Text(value == nil ? title : "\(title): ")
                .font(.system(size: 13, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
            if let value {
                Text(value)
                    .font(.system(size: 13, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .padding(.trailing, 10)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

}

// MARK: - Helpers

extension NavigationToolTableView {

    init(item: NavigationToolItem) {
        title = item.title
        value = item.value
        didSelect = item.didSelect
    }
}
