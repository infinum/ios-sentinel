//
//  View+Share.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 01.04.2025..
//

import SwiftUI

struct Share: ViewModifier {

    @Binding var showShare: Bool
    let activityItems: [Any]
    let didFinish: () -> Void

    func body(content: Content) -> some View {
        content
            #if os(macOS)
            .background(
                SharingsPicker(
                    isPresented: $showShare,
                    sharingItems: activityItems,
                    didFinish: didFinish
                )
            )
            #else
            .sheet(isPresented: $showShare) {
                ActivityViewController(
                    activityItems: activityItems,
                    applicationActivities: nil,
                    didFinish: didFinish
                )
            }
            #endif
    }
}

public extension View {

    func share(showShare: Binding<Bool>, items: [Any], didFinish: @escaping () -> Void) -> some View {
        modifier(Share(showShare: showShare, activityItems: items, didFinish: didFinish))
    }
}
