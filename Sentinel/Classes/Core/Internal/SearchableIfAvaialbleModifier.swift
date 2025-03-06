//
//  SearchableIfAvaialbleModifier.swift
//  Pods
//
//  Created by Zvonimir Medak on 28.02.2025..
//

import SwiftUI

struct SearchableIfAvaialbleModifier: ViewModifier {

    @Binding var text: String
    let prompt: String

    func body(content: Content) -> some View {
        #if os(iOS)
        if #available(iOS 15, *) {
            content
                .searchable(text: $text, placement: .toolbar, prompt: prompt)
        } else {
            content
        }
        #else
        content
            .searchable(text: $text, placement: .sidebar, prompt: prompt)
        #endif
    }

}

extension View {

    func searchableIfAvailable(text: Binding<String>, prompt: String) -> some View {
        self.modifier(SearchableIfAvaialbleModifier(text: text, prompt: prompt))
    }

}
