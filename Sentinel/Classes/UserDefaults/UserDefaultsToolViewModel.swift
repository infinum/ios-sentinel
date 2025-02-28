//
//  UserDefaultsToolViewModel.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 21.01.2025..
//

import Foundation

final class UserDefaultsToolViewModel: ObservableObject {

    // MARK: - Internal properties

    @Published var sections: [ToolTableSection] = []
    let name: String

    // MARK: - Private properties

    private let userDefaults: UserDefaults

    // MARK: - Init

    init(name: String, userDefaults: UserDefaults = .standard) {
        self.name = name
        self.userDefaults = userDefaults
    }

    func updateSections() {
        sections = createSectionItems(with: userDefaults)
    }
}

// MARK: - Item creation

private extension UserDefaultsToolViewModel {

    func createSectionItems(with userDefaults: UserDefaults) -> [ToolTableSection] {
        let items = userDefaults.dictionaryRepresentation()
            .sorted { $0.key < $1.key }
            .map { (key, value) in
                #if os(macOS)
                ToolTableItem.navigation(
                    NavigationToolItem(
                        title: key,
                        value: String(describing: value),
                        didSelect: {
                            UserDefaultsToolDetailView(
                                viewModel: UserDefaultsToolDetailViewModel(
                                    value: String(describing: value),
                                    title: key,
                                    userDefaults: userDefaults,
                                    didDeleteProperty: { [unowned self] in sections = createSectionItems(with: userDefaults) }
                                ),
                                selection: $0
                            )
                        }
                    )
                )
                #else
                ToolTableItem.navigation(
                    NavigationToolItem(
                        title: key,
                        value: String(describing: value),
                        didSelect: {
                            UserDefaultsToolDetailView(
                                viewModel: UserDefaultsToolDetailViewModel(
                                    value: String(describing: value),
                                    title: key,
                                    userDefaults: userDefaults,
                                    didDeleteProperty: nil // onAppear will update the screen on iOS
                                )
                            )
                        }
                    )
                )
                #endif
            }

        return [ToolTableSection(items: items)]
    }
}

