//
//  TextEditingToolViewModel.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 28.11.2024..
//

import Foundation

final class TextEditingToolViewModel: ObservableObject {

    // MARK: - Internal properties -

    @Published var value: String
    let title: String
    let didPressSave: (String) -> Void

    // MARK: - Init -

    init(value: String, title: String, didPressSave: @escaping (String) -> Void) {
        self.value = value
        self.title = title
        self.didPressSave = didPressSave
    }
}
