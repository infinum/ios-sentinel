//
//  View+PushedListTopMargin.swift
//  Sentinel
//
//  Created by Nikola Simunko on 13.10.2026..
//

import SwiftUI

extension View {

    /// Restores the gap between a pushed list and the navigation title or search bar above it.
    ///
    /// On iOS 26, a list pushed inside the Sentinel sheet lays its first section out directly against
    /// the bar above it, while tab root lists, and every list on earlier versions, get about 16 points.
    @ViewBuilder
    func pushedListTopMargin(isPushed: Bool) -> some View {
        #if os(iOS)
        if #available(iOS 26.0, *), isPushed {
            contentMargins(.top, 16, for: .scrollContent)
        } else {
            self
        }
        #else
        self
        #endif
    }
}
