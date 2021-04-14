//
//  BugsnatchTool.swift
//  ToolBox
//
//  Created by Vlaho Poluta on 31/07/2020.
//

import UIKit
import Bugsnatch

public class BugsnatchTool: Tool, Triggerable {
    public weak var delegate: TriggerDelegate?

    public init(
        triggerActionConfig: TriggerActionConfig? = nil,
        localization: BugsnatchLocalizationConfig = BugsnatchLocalizationConfig(),
        shouldShowBundleId: Bool = false,
        shouldShowDeviceOrientation: Bool = false,
        versionBuildNumberDisplayType: VersionBuildNumberDisplayType = .separated,
        extraDebugInfoDelegate: BugsnatchExtraDebugInfoDelegate? = nil
    ) {
        let configuration = BugsnatchConfig(
            trigger: self,
            triggerActionConfig: triggerActionConfig,
            localization: localization,
            shouldShowBundleId: shouldShowBundleId,
            shouldShowDeviceOrientation: shouldShowDeviceOrientation,
            versionBuildNumberDisplayType: versionBuildNumberDisplayType,
            extraDebugInfoDelegate: extraDebugInfoDelegate
        )
        Bugsnatch.shared.setup(config: configuration)
    }
    
    public var name: String { "Bugsnatch" }
    public func presentPreview(from viewController: UIViewController) {
        delegate?.didTrigger()
    }
}
