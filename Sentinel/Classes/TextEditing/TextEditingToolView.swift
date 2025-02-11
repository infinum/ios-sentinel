//
//  TextEditingToolView.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 28.11.2024..
//

import SwiftUI

struct TextEditingToolView: View {

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var viewModel: TextEditingToolViewModel
    #if os(macOS)
    @Binding var selection: String?
    #endif

    var body: some View {
        VStack(spacing: 10) {
            TextField(viewModel.title, text: $viewModel.value)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

            Button(action: {
                viewModel.didPressSave(viewModel.value)
                #if os(macOS)
                selection = nil
                #else
                presentationMode.wrappedValue.dismiss() // on macOS dismisses the whole window which isn't desired
                #endif
            }) {
                Text("Save")
            }
        }
        .padding(.horizontal, 16)
        .navigationTitle(viewModel.title)
    }
}
