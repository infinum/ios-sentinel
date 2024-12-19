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

    var body: some View {
        VStack(spacing: 10) {
            TextField(viewModel.title, text: $viewModel.value)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

            Button(action: {
                viewModel.didPressSave(viewModel.value)
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Save")
            }
        }
        .padding(.horizontal, 16)
        .navigationTitle(viewModel.title)
    }
}
