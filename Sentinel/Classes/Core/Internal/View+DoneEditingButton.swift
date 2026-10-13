//
//  View+DoneEditingButton.swift
//  Sentinel
//
//  Created by Nikola Simunko on 13.10.2026..
//

import SwiftUI

extension View {

    /// Shows a Done button in the navigation bar while a field is being edited, for fields whose keyboard
    /// has no return key that ends editing, such as a text editor. Does nothing on macOS.
    ///
    /// The button goes in the navigation bar rather than above the keyboard, because iOS 26 floats the
    /// keyboard's toolbar over the bottom of the screen, where these screens keep their own buttons.
    ///
    /// - Parameters:
    ///     - isEditing: Whether a field on the screen has focus.
    ///     - action: Ends editing, usually by clearing the view's `FocusState`.
    @ViewBuilder
    func doneEditingButton(isEditing: Bool, action: @escaping () -> Void) -> some View {
        #if os(iOS)
        toolbar {
            ToolbarItem(placement: .confirmationAction) {
                if isEditing {
                    Button("Done", action: action)
                }
            }
        }
        #else
        self
        #endif
    }
}
