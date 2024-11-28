//
//  PerformanceInfoViewModel.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 28.11.2024..
//

import Foundation

final class PerformanceInfoViewModel: ObservableObject {

    @Published var value: String
    let item: PerformanceInfoItem

    private var timer: Timer?

    init(item: PerformanceInfoItem) {
        self.item = item
        value = item.valueDidChange()
    }

}

extension PerformanceInfoViewModel {

    func startTimer() {
        invalidateTimer()
        initializeTimer()
    }
}

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
