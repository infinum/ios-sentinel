//
//  PerformanceInfoViewModel.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 28.11.2024..
//

import Foundation

final class PerformanceInfoViewModel: ObservableObject {

    // MARK: - Internal properties

    @Published var value: String
    let item: PerformanceInfoItem

    // MARK: - Private properties

    private var timer: Timer?

    // MARK: - Init

    init(item: PerformanceInfoItem) {
        self.item = item
        value = item.valueDidChange()
    }
}

// MARK: - Extensions -

// MARK: - Internal methods

extension PerformanceInfoViewModel {

    func startTimer() {
        invalidateTimer()
        initializeTimer()
    }
}

// MARK: - Timer helpers

private extension PerformanceInfoViewModel {

    func initializeTimer() {
        timer = Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(updatePerformanceInfo),
            userInfo: nil,
            repeats: true
        )
    }

    func invalidateTimer() {
        timer?.invalidate()
    }

    @objc func updatePerformanceInfo() {
        value = item.valueDidChange()
    }

}
