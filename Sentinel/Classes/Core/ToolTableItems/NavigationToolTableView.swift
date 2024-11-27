//
//  NavigationToolTableView.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 27.11.2024..
//

import SwiftUI

struct NavigationToolTableView: View {

    let title: String
    let didSelect: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onTapGesture { didSelect() }
    }

}

extension NavigationToolTableView {

    init(item: NavigationToolItem) {
        title = item.title
        didSelect = item.didSelect
    }
}
