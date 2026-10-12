//
//  ClearAppDataViewModel.swift
//  Sentinel
//
//  Created by Nikola Simunko on 22.09.2025..
//

import Foundation

#if os(iOS)

final class ClearAppDataViewModel: ObservableObject {

    /// Both alerts are driven by a single value, so the view attaches one `alert` modifier and the
    /// confirmation and result alerts can never compete to be presented.
    enum AlertKind: Identifiable {
        case confirmation
        case result(ClearAppDataReport)

        var id: String {
            switch self {
            case .confirmation: return "confirmation"
            case .result: return "result"
            }
        }
    }

    /// Presenting an alert while the previous one is still dismissing swallows it.
    private static let alertDelay: TimeInterval = 0.33

    // MARK: - Public properties
    let name: String

    @Published var activeAlert: AlertKind?
    @Published private(set) var isClearing = false

    // MARK: - Lifecycle
    init(name: String) {
        self.name = name
    }
}

// MARK: - Actions

extension ClearAppDataViewModel {

    func didTapClearAll() {
        activeAlert = .confirmation
    }

    func didConfirmClearAll() {
        isClearing = true
        AppDataCleaner.clearAll { [weak self] report in
            self?.isClearing = false
            DispatchQueue.main.asyncAfter(deadline: .now() + Self.alertDelay) {
                self?.activeAlert = .result(report)
            }
        }
    }
}

#endif
