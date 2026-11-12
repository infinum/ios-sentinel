//
//  SampleCrashes.swift
//  Example-iOS
//
//  Created by Karlo Čeh on 15.10.2026..
//

import UIKit

/// Fills the Crash Detection tool with realistic crashes, so its list and detail screens can be checked
/// without crashing the app over and over.
///
/// `CrashModel` is internal to Sentinel, so this writes the same JSON files `CrashFileManager` reads
/// (`nsexception_crashes.json` and `signal_crashes.json` in the Documents directory).
enum SampleCrashes {

    // MARK: - File format

    fileprivate struct Record: Codable {

        struct Details: Codable {
            struct DeviceInfo: Codable {
                let model: String
                let name: String
                let systemVersion: String
                let UUID: String
            }

            let name: String
            let date: Date
            let deviceInfo: DeviceInfo
        }

        struct Trace: Codable {
            let title: String
            let detail: String
        }

        let type: String
        let details: Details
        let traces: [Trace]
    }

    fileprivate struct Sample {
        let type: String
        /// What Sentinel stores as the crash name: the exception name followed by its reason, or `Signal <NAME>`
        let name: String
        let secondsAgo: TimeInterval
        let frames: [Frame]
    }

    fileprivate struct Frame {
        let image: String
        let symbol: String
        let offset: Int

        init(_ image: String, _ symbol: String, _ offset: Int) {
            self.image = image
            self.symbol = symbol
            self.offset = offset
        }
    }

    // MARK: - Public

    /// Appends the sample crashes to whatever has been recorded already
    static func seed() {
        let now = Date()
        let deviceInfo = Record.Details.DeviceInfo(
            model: UIDevice.current.model,
            name: UIDevice.current.name,
            systemVersion: UIDevice.current.systemVersion,
            UUID: UIDevice.current.identifierForVendor?.uuidString ?? "???"
        )

        let records = samples.map { sample in
            Record(
                type: sample.type,
                details: .init(
                    name: sample.name,
                    date: now.addingTimeInterval(-sample.secondsAgo),
                    deviceInfo: deviceInfo
                ),
                traces: traces(for: sample.frames)
            )
        }

        for type in ["nsexception", "signal"] {
            append(records.filter { $0.type == type }, to: "\(type)_crashes.json")
        }
    }
}

// MARK: - Storage

private extension SampleCrashes {

    static func append(_ records: [Record], to fileName: String) {
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let url = directory.appendingPathComponent(fileName)

        let existing = (try? Data(contentsOf: url)).flatMap { try? JSONDecoder().decode([Record].self, from: $0) } ?? []
        guard let data = try? JSONEncoder().encode(existing + records) else { return }
        try? data.write(to: url)
    }
}

// MARK: - Stack traces

private extension SampleCrashes {

    /// Formats frames like `Thread.callStackSymbols`, e.g. `3   CoreFoundation   0x0000000180a3d1f4 __exceptionPreprocess + 164`
    static func traces(for frames: [Frame]) -> [Record.Trace] {
        frames.enumerated().map { index, frame in
            let address = address(for: frame)
            let title = "\(String(index).padding(toLength: 4, withPad: " ", startingAt: 0))"
                + "\(frame.image.padding(toLength: 35, withPad: " ", startingAt: 0))"
                + "0x\(String(format: "%016lx", address)) \(frame.symbol) + \(frame.offset)"
            return Record.Trace(title: title, detail: detail(from: title))
        }
    }

    /// Stable, plausible-looking addresses: every image has its own base, and the offset moves with the frame
    static func address(for frame: Frame) -> UInt {
        let bases: [String: UInt] = [
            "Example-iOS": 0x1_0268_4000,
            "CoreFoundation": 0x1_8036_a000,
            "UIKitCore": 0x1_8585_0000,
            "SwiftUI": 0x1_c2d0_0000,
            "SwiftUICore": 0x1_c1b3_0000,
            "Foundation": 0x1_8123_c000,
            "GraphicsServices": 0x1_e8f0_0000,
            "libobjc.A.dylib": 0x1_8028_0000,
            "libc++abi.dylib": 0x1_f021_c000,
            "libsystem_kernel.dylib": 0x1_f0a7_8000,
            "libsystem_pthread.dylib": 0x2_1ce1_4000,
            "libsystem_c.dylib": 0x1_dc6d_8000,
            "libsystem_malloc.dylib": 0x1_dd1c_4000,
            "libsystem_platform.dylib": 0x2_1eb2_c000,
            "libswiftCore.dylib": 0x1_ab14_0000,
            "libdispatch.dylib": 0x1_8021_4000,
            "dyld": 0x1_a7e4_c000
        ]
        let base = bases[frame.image] ?? 0x1_8000_0000
        // `hashValue` is seeded per launch, so derive the symbol's position from its bytes instead
        let symbolOffset = frame.symbol.utf8.reduce(5381) { ($0 &* 33 &+ Int($1)) & 0x3_ffff } & ~0x3
        return base + UInt(frame.offset + symbolOffset)
    }

    /// Mirrors how Sentinel derives the details of a swift symbol, so the rows look like the real ones
    static func detail(from symbol: String) -> String {
        guard
            let regex = try? NSRegularExpression(pattern: "\\$s(\\S+)\\d+", options: .caseInsensitive),
            let match = regex.firstMatch(in: symbol, range: NSRange(location: 0, length: symbol.utf16.count)),
            let range = Range(match.range(at: 1), in: symbol)
        else { return "" }

        return "Class: \(symbol[range])\n"
    }
}

// MARK: - Samples

private extension SampleCrashes {

    static let samples: [Sample] = [
        Sample(
            type: "nsexception",
            name: "NSRangeException: *** -[__NSArrayM objectAtIndex:]: index 7 beyond bounds [0 .. 4]",
            secondsAgo: 12 * 60 + 8,
            frames: uncaughtExceptionHead + [
                Frame("CoreFoundation", "-[__NSArrayM objectAtIndex:]", 188),
                Frame("Example-iOS", "$s11Example_iOS14FeedDataSourceC4item2atAA0D4ItemVSi_tF", 212),
                Frame("Example-iOS", "$s11Example_iOS18FeedViewControllerC9tableView_12cellForRowAtSo07UITableF4CellCSo0jF0C_10Foundation9IndexPathVtF", 436),
                Frame("Example-iOS", "$s11Example_iOS18FeedViewControllerC9tableView_12cellForRowAtSo07UITableF4CellCSo0jF0C_10Foundation9IndexPathVtFTo", 112),
                Frame("UIKitCore", "-[UITableView _createPreparedCellForGlobalRow:withIndexPath:willDisplay:]", 780),
                Frame("UIKitCore", "-[UITableView _updateVisibleCellsNow:isRecursive:]", 2356),
                Frame("UIKitCore", "-[UITableView layoutSubviews]", 160),
                Frame("UIKitCore", "-[UIView(CALayerDelegate) layoutSublayersOfLayer:]", 2340)
            ] + mainThreadTail
        ),
        Sample(
            type: "nsexception",
            name: "NSInvalidArgumentException: -[__NSCFString setAvatarURL:]: unrecognized selector sent to instance 0x600000c24120",
            secondsAgo: 47 * 60 + 31,
            frames: uncaughtExceptionHead + [
                Frame("CoreFoundation", "___forwarding___", 1472),
                Frame("CoreFoundation", "_CF_forwarding_prep_0", 96),
                Frame("Example-iOS", "$s11Example_iOS21ProfileViewControllerC4load7profileyAA0D0V_tF", 304),
                Frame("Example-iOS", "$s11Example_iOS21ProfileViewControllerC11viewDidLoadyyFTo", 88),
                Frame("UIKitCore", "-[UIViewController loadViewIfRequired]", 1056),
                Frame("UIKitCore", "-[UINavigationController _startCustomTransition:]", 1320),
                Frame("UIKitCore", "-[UINavigationController _startDeferredTransitionIfNeeded:]", 880),
                Frame("UIKitCore", "-[UINavigationController __viewWillLayoutSubviews]", 168)
            ] + mainThreadTail
        ),
        Sample(
            type: "nsexception",
            name: "NSInternalInconsistencyException: attempt to insert row 4 into section 0, but there are only 3 rows in section 0 after the update",
            secondsAgo: 5 * 3600 + 20 * 60 + 14,
            frames: uncaughtExceptionHead + [
                Frame("UIKitCore", "-[UITableView _endCellAnimationsWithContext:]", 15868),
                Frame("UIKitCore", "-[UITableView endUpdates]", 52),
                Frame("Example-iOS", "$s11Example_iOS18FeedViewControllerC6insert4itemyAA0D4ItemV_tF", 528),
                Frame("Example-iOS", "$s11Example_iOS18FeedViewControllerC15refreshFinishedyyFyycfU_", 160),
                Frame("libdispatch.dylib", "_dispatch_call_block_and_release", 32),
                Frame("libdispatch.dylib", "_dispatch_client_callout", 20),
                Frame("libdispatch.dylib", "_dispatch_main_queue_drain", 980),
                Frame("libdispatch.dylib", "_dispatch_main_queue_callback_4CF", 44),
                Frame("CoreFoundation", "__CFRUNLOOP_IS_SERVICING_THE_MAIN_DISPATCH_QUEUE__", 16)
            ] + runLoopTail
        ),
        Sample(
            type: "nsexception",
            name: "NSUnknownKeyException: [<Example_iOS.SettingsModel 0x600003d1c2a0> valueForUndefinedKey:]: this class is not key value coding-compliant for the key displayName.",
            secondsAgo: 26 * 3600 + 3 * 60 + 52,
            frames: uncaughtExceptionHead + [
                Frame("Foundation", "-[NSObject(NSKeyValueCoding) valueForUndefinedKey:]", 232),
                Frame("Foundation", "-[NSObject(NSKeyValueCoding) valueForKey:]", 336),
                Frame("Example-iOS", "$s11Example_iOS13SettingsModelC5value6forKeySSSgSS_tF", 240),
                Frame("Example-iOS", "$s11Example_iOS12SettingsViewV4bodyQrvgyAA0D3RowVcfU_", 396),
                Frame("SwiftUI", "$s7SwiftUI4ViewPAAE12_makeContent4view6inputsAA01_B7OutputsV_AA01_B10GraphInputsVtFZ", 148),
                Frame("SwiftUICore", "$s7SwiftUI15ViewGraphUpdate6updateyyF", 1204)
            ] + mainThreadTail
        ),
        Sample(
            type: "signal",
            name: "Signal SIGTRAP",
            secondsAgo: 3 * 3600 + 41 * 60 + 9,
            frames: signalHead + [
                Frame("Example-iOS", "$s11Example_iOS14CheckoutLoaderC6submit5orderyAA5OrderV_tF", 1124),
                Frame("Example-iOS", "$s11Example_iOS12CheckoutViewV4bodyQrvgyycfU_", 296),
                Frame("SwiftUI", "$s7SwiftUI18StyleContextWriterVAAE5writeyyF", 284),
                Frame("SwiftUI", "$s7SwiftUI6ButtonV6actionyyF", 112)
            ] + mainThreadTail
        ),
        Sample(
            type: "signal",
            name: "Signal SIGABRT",
            secondsAgo: 9 * 3600 + 15 * 60 + 47,
            frames: signalHead + [
                Frame("libsystem_kernel.dylib", "__pthread_kill", 8),
                Frame("libsystem_pthread.dylib", "pthread_kill", 268),
                Frame("libsystem_c.dylib", "abort", 128),
                Frame("libsystem_malloc.dylib", "malloc_vreport", 896),
                Frame("libsystem_malloc.dylib", "malloc_zone_error", 104),
                Frame("libsystem_malloc.dylib", "free", 436),
                Frame("Example-iOS", "$s11Example_iOS12AudioBufferPoolC7release6bufferyySvF", 188),
                Frame("Example-iOS", "$s11Example_iOS12AudioBufferPoolCfD", 120),
                Frame("libswiftCore.dylib", "_swift_release_dealloc", 32),
                Frame("Example-iOS", "$s11Example_iOS15PlayerControllerC4stopyyF", 264)
            ] + mainThreadTail
        ),
        Sample(
            type: "signal",
            name: "Signal SIGSEGV",
            secondsAgo: 2 * 86400 + 4 * 3600 + 27 * 60 + 3,
            frames: signalHead + [
                Frame("libobjc.A.dylib", "objc_release", 16),
                Frame("Example-iOS", "$s11Example_iOS16ImageCacheEntryCfD", 84),
                Frame("libswiftCore.dylib", "_swift_release_dealloc", 32),
                Frame("Example-iOS", "$s11Example_iOS10ImageCacheC5evict3keyySS_tF", 372),
                Frame("Example-iOS", "$s11Example_iOS10ImageCacheC21didReceiveMemoryWarningyyFyycfU_", 148),
                Frame("libdispatch.dylib", "_dispatch_call_block_and_release", 32),
                Frame("libdispatch.dylib", "_dispatch_client_callout", 20),
                Frame("libdispatch.dylib", "_dispatch_lane_serial_drain", 744),
                Frame("libdispatch.dylib", "_dispatch_lane_invoke", 380),
                Frame("libdispatch.dylib", "_dispatch_workloop_worker_thread", 648),
                Frame("libsystem_pthread.dylib", "_pthread_wqthread", 288),
                Frame("libsystem_pthread.dylib", "start_wqthread", 8)
            ]
        )
    ]

    /// The frames Sentinel itself adds while handling an uncaught exception, followed by what the runtime does to get there
    static let uncaughtExceptionHead: [Frame] = [
        Frame("Example-iOS", "$s8Sentinel10CrashModelV4type7details6tracesAcA0C4TypeO_AC7DetailsVSayAC10StackTraceVGtcfcfA1_", 180),
        Frame("Example-iOS", "$s8Sentinel12CrashHandlerC33registerUncaughtExceptionHandler09exceptionF0yySi_So11NSExceptionCSgSStcSgFyAGSgAISStcfU_", 508),
        Frame("Example-iOS", "$s8Sentinel24UncaughtExceptionHandler9exceptionySo11NSExceptionC_tF", 276),
        Frame("Example-iOS", "$s8Sentinel24UncaughtExceptionHandler9exceptionySo11NSExceptionC_tFTo", 36),
        Frame("libobjc.A.dylib", "_objc_terminate()", 144),
        Frame("libc++abi.dylib", "std::__terminate(void (*)())", 16),
        Frame("libc++abi.dylib", "__cxa_throw", 140),
        Frame("libobjc.A.dylib", "objc_exception_throw", 88),
        Frame("CoreFoundation", "___exceptionPreprocess", 164)
    ]

    /// The frames Sentinel itself adds while handling a signal, ending with the kernel's signal trampoline
    static let signalHead: [Frame] = [
        Frame("Example-iOS", "$s8Sentinel10CrashModelV4type7details6tracesAcA0C4TypeO_AC7DetailsVSayAC10StackTraceVGtcfcfA1_", 180),
        Frame("Example-iOS", "$s8Sentinel12CrashHandlerC32registerSignalExceptionHandler09exceptionF0yySi_So11NSExceptionCSgSStcSgFyAGSgAISStcfU_", 484),
        Frame("Example-iOS", "$s8Sentinel18crashSignalHandler33_3E5A2F1C9B7D4A60E8F1D2C3B4A59687LL_4info7contextys5Int32V_SpySo9__siginfoGSgSvSgtF", 340),
        Frame("libsystem_platform.dylib", "_sigtramp", 56)
    ]

    static let mainThreadTail: [Frame] = [
        Frame("CoreFoundation", "__CFRUNLOOP_IS_CALLING_OUT_TO_A_BLOCK__", 28),
        Frame("CoreFoundation", "__CFRunLoopDoBlocks", 356)
    ] + runLoopTail

    static let runLoopTail: [Frame] = [
        Frame("CoreFoundation", "__CFRunLoopRun", 884),
        Frame("CoreFoundation", "CFRunLoopRunSpecific", 572),
        Frame("GraphicsServices", "GSEventRunModal", 168),
        Frame("UIKitCore", "-[UIApplication _run]", 816),
        Frame("UIKitCore", "UIApplicationMain", 340),
        Frame("Example-iOS", "main", 64),
        Frame("dyld", "start", 2724)
    ]
}
