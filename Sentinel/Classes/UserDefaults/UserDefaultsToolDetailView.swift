//
//  UserDefaultsToolDetailView.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 28.11.2024..
//

import SwiftUI

struct UserDefaultsToolDetailView: View {

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var viewModel: UserDefaultsToolDetailViewModel
    #if os(macOS)
    @Binding var selection: String?
    #endif

    var body: some View {
        VStack(spacing: 10) {
            Text(viewModel.title)
                .font(.title1Bold)
                .padding(.top, 20)

            TextEditor(text: $viewModel.value)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .padding(.top, 40)

            HStack(spacing: 32) {
                Button(action: {
                    viewModel.didPressDelete()
                    #if os(macOS)
                    selection = nil
                    #else
                    presentationMode.wrappedValue.dismiss() // on macOS dismisses the whole window which isn't desired
                    #endif
                }, label: { Text("Delete") })

                Button(action: {
                    viewModel.didPressSave()
                    #if os(macOS)
                    selection = nil
                    #else
                    presentationMode.wrappedValue.dismiss() // on macOS dismisses the whole window which isn't desired
                    #endif
                }, label: { Text("Save") })
            }
            .padding(.bottom, 20)
        }
        .padding(.horizontal, 16)
    }
}
