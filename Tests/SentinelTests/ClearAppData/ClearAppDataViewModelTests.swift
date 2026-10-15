//
//  ClearAppDataViewModelTests.swift
//  SentinelTests
//
//  Created by Nikola Simunko on 12.10.2026..
//

#if os(iOS)
import Testing
@testable import Sentinel

@Suite("Clear app data view model")
struct ClearAppDataViewModelTests {

    @Test("Starts idle without an alert")
    func initialState() {
        let viewModel = ClearAppDataViewModel(name: "Clear")

        #expect(viewModel.name == "Clear")
        #expect(viewModel.activeAlert == nil)
        #expect(!viewModel.isClearing)
    }

    @Test("Tapping clear asks for confirmation before clearing anything")
    func tapAsksForConfirmation() {
        let viewModel = ClearAppDataViewModel(name: "Clear")

        viewModel.didTapClearAll()

        #expect(viewModel.activeAlert?.id == "confirmation")
        #expect(!viewModel.isClearing)
    }

    @Test("Alert ids distinguish confirmation from result")
    func alertIds() {
        #expect(ClearAppDataViewModel.AlertKind.confirmation.id == "confirmation")
        #expect(ClearAppDataViewModel.AlertKind.result(ClearAppDataReport(failures: [])).id == "result")
    }

    @Test("The tool keeps its name")
    func toolName() {
        #expect(ClearAppDataTool().name == "Clear App Data")
        #expect(ClearAppDataTool(name: "Wipe").name == "Wipe")
    }
}
#endif
