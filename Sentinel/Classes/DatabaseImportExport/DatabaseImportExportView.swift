//
//  DatabaseImportExportView.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 12.03.2025..
//

import SwiftUI
import UniformTypeIdentifiers

struct DatabaseImportExportView: View {

    @ObservedObject var viewModel: DatabaseImportExportViewModel

    @State private var showPicker = false
    @State private var showShare = false

    var body: some View {
        VStack(spacing: 30) {
            Button(action: { showPicker = true }) {
                Text("Import Database")
            }

            Button(action: { viewModel.exportDatabase() }) {
                Text("Export Database")
            }
            .fileImporter(isPresented: $showPicker, allowedContentTypes: viewModel.allowedTypes) {
                guard case .success(let url) = $0 else { return }
                viewModel.importDatabase(url: url)
            }
            .onChange(of: viewModel.selectedURL) {
                guard $0 != nil else { return }
                showShare = true
            }
            #if os(macOS)
            .background(
                SharingsPicker(
                    isPresented: $showShare,
                    sharingItems: [viewModel.selectedURL as Any],
                    didFinish: { viewModel.selectedURL = nil }
                )
            )
            #else
            .sheet(isPresented: $showShare) {
                ActivityViewController(
                    activityItems: [viewModel.selectedURL as Any],
                    applicationActivities: nil,
                    didFinish: { viewModel.selectedURL = nil }
                )
            }
            #endif
        }
    }
}

#if os(macOS)

struct SharingsPicker: NSViewRepresentable {
    @Binding var isPresented: Bool
    let sharingItems: [Any]
    let didFinish: () -> Void

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        if isPresented {
            let picker = NSSharingServicePicker(items: sharingItems)
            picker.delegate = context.coordinator

            // !! MUST BE CALLED IN ASYNC, otherwise blocks update
            DispatchQueue.main.async {
                picker.show(relativeTo: .zero, of: nsView, preferredEdge: .minY)
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(owner: self)
    }

    class Coordinator: NSObject, NSSharingServicePickerDelegate {
        let owner: SharingsPicker

        init(owner: SharingsPicker) {
            self.owner = owner
        }

        func sharingServicePicker(_ sharingServicePicker: NSSharingServicePicker, didChoose service: NSSharingService?) {

            // do here whatever more needed here with selected service

            sharingServicePicker.delegate = nil   // << cleanup
            self.owner.isPresented = false        // << dismiss
            owner.didFinish()
        }
    }
}

#endif

#if os(iOS)
struct ActivityViewController: UIViewControllerRepresentable {

    @Environment(\.presentationMode) var presentationMode

    let activityItems: [Any]
    let applicationActivities: [UIActivity]?
    let didFinish: () -> Void

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        controller.completionWithItemsHandler = { (activityType, completed, returnedItems, error) in
            self.presentationMode.wrappedValue.dismiss()
            didFinish()
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {}

}
#endif
