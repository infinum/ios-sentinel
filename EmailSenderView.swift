//
//  EmailSenderView.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 10.12.2024..
//

import SwiftUI
import MessageUI

struct EmailSenderView: UIViewControllerRepresentable {

    @Environment(\.presentationMode) var presentationMode
    @State var showError: Bool = false

    let mailData: MailData

    func makeUIViewController(context: Context) -> some UIViewController {
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = context.coordinator
        mail.setToRecipients(mailData.recipients)
        mail.setCcRecipients(mailData.ccRecipients)
        mail.setBccRecipients(mailData.bccRecipients)
        mail.setSubject(mailData.subject)
        mail.setMessageBody(mailData.message, isHTML: mailData.isHTML)

        mailData
            .attachments
            .forEach {
                mail.addAttachmentData(
                    $0.data,
                    mimeType: $0.mimeType,
                    fileName: $0.fileName
                )
            }

        return mail as UIViewController
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        // Nothing to do here
    }

    static func canSendEmail() -> Bool {
        MFMailComposeViewController.canSendMail()
    }
}

extension EmailSenderView {

    final class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: EmailSenderView

        init(_ parent: EmailSenderView) {
            self.parent = parent
        }

        func mailComposeController(
            _ controller: MFMailComposeViewController,
            didFinishWith result: MFMailComposeResult,
            error: Error?
        ) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

}
