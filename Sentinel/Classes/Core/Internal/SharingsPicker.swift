//
//  SharingsPicker.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 01.04.2025..
//

import SwiftUI

#if os(macOS)
struct SharingsPicker: NSViewRepresentable {
    @Binding var isPresented: Bool
    let sharingItems: [Any]
    let didFinish: () -> Void

    func makeNSView(context: Context) -> NSView {
        NSView()
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        if isPresented {
            let picker = NSSharingServicePicker(items: sharingItems)
            picker.delegate = context.coordinator

            DispatchQueue.main.async {
                picker.show(relativeTo: .zero, of: nsView, preferredEdge: .minY)
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(picker: self)
    }

    class Coordinator: NSObject, NSSharingServicePickerDelegate {
        let picker: SharingsPicker

        init(picker: SharingsPicker) {
            self.picker = picker
        }

        func sharingServicePicker(_ sharingServicePicker: NSSharingServicePicker, didChoose service: NSSharingService?) {
            sharingServicePicker.delegate = nil
            picker.isPresented = false
            picker.didFinish()
        }
    }
}
#endif
