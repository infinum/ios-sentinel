//
//  SentinelListViewModel.swift
//  Pods
//
//  Created by Zvonimir Medak on 28.02.2025..
//

import Combine

final class SentinelListViewModel: ObservableObject {

    // MARK: - Internal properties

    @Published var serachText: String = ""
    @Published var sections: [ToolTableSection]
    let initialSections: [ToolTableSection]

    // MARK: - Private properties

    private var cancellables: Set<AnyCancellable> = .init()

    // MARK: - Init

    init(initialSections: [ToolTableSection]) {
        self.initialSections = initialSections
        sections = initialSections

        setupSearchObserving()
    }
}

private extension SentinelListViewModel {

    func setupSearchObserving() {
        $serachText
            .sink { [unowned self] value in
                guard value.isEmpty else {
                    let filteredItems = initialSections.flatMap(\.items).filter { $0.id.lowercased().contains(value.lowercased()) }
                    sections = [ToolTableSection(items: filteredItems)]
                    return
                }
                sections = initialSections
            }
            .store(in: &cancellables)
    }
}
