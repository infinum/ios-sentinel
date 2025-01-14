//
//  UserDefaultsToolView.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 28.11.2024..
//

import SwiftUI

struct UserDefaultsToolView: View {

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var viewModel: UserDefaultsToolViewModel

    var body: some View {
        VStack(spacing: 10) {
            Text(viewModel.value)
                .contextMenu(ContextMenu(menuItems: {
                    Button("Copy", action: {
                        #if os(macOS)
                        NSPasteboard.general.setString(viewModel.value, forType: .string)
                        #else
                        UIPasteboard.general.string = viewModel.value
                        #endif
                    })
                }))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

            Button(action: {
                viewModel.didPressDelete()
                #if !os(macOS)
                presentationMode.wrappedValue.dismiss() // on macOS dismisses the whole window which isn't desired
                #endif
            }, label: { Text("Delete") })
            .padding(.bottom, 20)
        }
        .padding(.horizontal, 16)
        .navigationTitle(viewModel.title)
    }
}
