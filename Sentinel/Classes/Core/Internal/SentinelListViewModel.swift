//
//  SentinelListViewModel.swift
//  Pods
//
//  Created by Zvonimir Medak on 28.02.2025..
//

import Combine

final class SentinelListViewModel: ObservableObject {

    // MARK: - Internal properties

    @Published var searchText: String = ""
    @Published var sections: [ToolTableSection]

    // MARK: - Private properties

    private var cancellables: Set<AnyCancellable> = .init()
    private let initialSections: [ToolTableSection]

    // MARK: - Init

    init(sections: [ToolTableSection]) {
        initialSections = sections
        self.sections = sections

        setupSearchObserving()
    }
}

private extension SentinelListViewModel {

    func setupSearchObserving() {
        $searchText
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
