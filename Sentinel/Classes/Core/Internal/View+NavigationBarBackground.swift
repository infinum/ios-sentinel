//
//  View+NavigationBarBackground.swift
//  Sentinel
//
//  Created by Nikola Simunko on 15.10.2026..
//

import SwiftUI

extension View {

    /// Gives the navigation bar a material background once content scrolls under it.
    ///
    /// On iOS 26, a bar inside the Sentinel sheet otherwise only gets the scroll edge effect, which leaves
    /// rows readable behind the title and the search field. Earlier versions already get a frosted bar.
    @ViewBuilder
    func navigationBarMaterialBackground() -> some View {
        #if os(iOS)
        if #available(iOS 26.0, *) {
            // Not forced with `.visible`: that keeps iOS 26's default background, which is just the edge
            // effect, and with `.bar` it covers the large title of a tab root at rest.
            toolbarBackground(.bar, for: .navigationBar)
        } else {
            self
        }
        #else
        self
        #endif
    }
}
