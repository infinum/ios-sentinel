//
//  TitleValueView.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 27.11.2024..
//

import SwiftUI

struct TitleValueView: View {

    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 10) {
            Text(title)
                .font(.system(size: 13, weight: .bold))

            Text(value)
                .font(.system(size: 13, weight: .regular))
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}

extension TitleValueView {

    init(item: CustomInfoTool.Item) {
        title = item.title
        value = item.value
    }

}
