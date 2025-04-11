//
//  ActivityViewController.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 01.04.2025..
//

import SwiftUI

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
