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
                        UIPasteboard.general.string = viewModel.value
                    })
                }))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

            Button(action: {
                viewModel.didPressDelete()
                presentationMode.wrappedValue.dismiss()
            }, label: { Text("Delete") })
        }
        .padding(.horizontal, 16)
        .navigationTitle(viewModel.title)
    }
}
