//
//  EmailSenderTool.swift
//  Sentinel
//
//  Created by Antonijo Bezmalinovic on 22.11.2023..
//

import Foundation
import MessageUI

@objcMembers
public final class EmailSenderTool: NSObject, Tool {

    // MARK: - Public properties -
    
    public var name: String { "Email Sender" }

    // MARK: - Private properties -

    private let getter: () -> (MailData)

    private var alertTitle: String
    private var alertMessage: String

    // MARK: - Lifecycle -

    init(
        getter: @escaping () -> (MailData),
        alertTitle: String = "Email Not Available",
        alertMessage: String = "Your device is not configured to send emails. Please set up an email account in Mail app or use another device."
    ) {
        self.getter = getter
        self.alertTitle = alertTitle
        self.alertMessage = alertMessage

        super.init()
    }
}

// MARK: - Private extension -

public extension EmailSenderTool {
    
    func presentPreview(from viewController: UIViewController) {
        createToolTable(viewController: viewController)
    }
}

extension EmailSenderTool: MFMailComposeViewControllerDelegate {
    
    public func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error: Error?
    ) {
        controller.dismiss(animated: true)
    }
}

// MARK: - Private extension -

private extension EmailSenderTool {
    
    func createToolTable(viewController: UIViewController) {
        
        if MFMailComposeViewController.canSendMail() {
            sendEmail(viewController: viewController)
        } else {
            // Show error or inform the user
            showEmailNotAvailableAlert(viewController: viewController)
        }
    }
            
    func sendEmail(viewController: UIViewController) {
        
        let mailData = getter()
        
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self
        mail.setToRecipients(mailData.toRecipients) // Replace with your recipient
        mail.setSubject(mailData.subject)
        mail.setMessageBody(mailData.message, isHTML: mailData.isHTML)

        mailData.attachments.map {
            guard let attechmentData = $0.data else { return }
            mail.addAttachmentData(attechmentData, mimeType: $0.mimeType, fileName: $0.fileName)
        }
            
        viewController.present(mail, animated: true)
    }
    
    func showEmailNotAvailableAlert(viewController: UIViewController) {
        let alert = UIAlertController(
            title: alertTitle,
            message: alertMessage,
            preferredStyle: .alert
        )

        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)

        viewController.present(alert, animated: true)
    }
}
