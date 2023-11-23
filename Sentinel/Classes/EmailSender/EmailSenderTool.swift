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
    
    public var name: String

    // MARK: - Private properties -

    private let getter: () -> (MailData)

    private var alertTitle: String
    private var alertMessage: String

    // MARK: - Lifecycle -
    /// email data  (subject, body, attachnebt...) is provided by 'getter' callback which should be implemented during Sentiel initialization step, for example:
    /// class SentinelInitializer {
    /// let configuration = Sentinel.Configuration(
    ///    trigger: Triggers.shake,
    ///    sourceScreenProvider: SourceScreenProviders.default,
    ///    tools: [
    ///     ...,
    ///        EmailSenderTool {
    ///            return DomeProvider.composeMail()
    ///        },
    ///     ....,
    ///     ]
    /// }
    /// name that will appear in Sentiel
    ///
    /// alertTitle && alertMessage describe alert content that will appear if device is not configured to send email's
    ///
    public init(
        getter: @escaping () -> (MailData),
        name: String = "Email Sender",
        alertTitle: String = "Email Not Available",
        alertMessage: String = "Your device is not configured to send emails. Please set up an email account in Mail app or use another device."
    ) {
        self.getter = getter
        self.name = name
        self.alertTitle = alertTitle
        self.alertMessage = alertMessage

        super.init()
    }
}

// MARK: - Private extension -

public extension EmailSenderTool {
    
    func presentPreview(from viewController: UIViewController) {
        presentEmailSender(viewController: viewController)
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
    
    func presentEmailSender(viewController: UIViewController) {
        guard MFMailComposeViewController.canSendMail() else {
            showEmailAlert(from: viewController)
            return
        }
        showSendEmail(from: viewController, mailData: getter())
    }
            
    func sendEmail(from viewController: UIViewController) {
        
        let mailData = getter()
        
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self
        mail.setToRecipients(mailData.recipients)
        mail.setCcRecipients(mailData.ccRecipients)
        mail.setBccRecipients(mailData.bccRecipients)
        mail.setSubject(mailData.subject)
        mail.setMessageBody(mailData.message, isHTML: mailData.isHTML)

        mailData.attachments.map {
            mail.addAttachmentData($0.data, mimeType: $0.mimeType, fileName: $0.fileName)
        }
            
        viewController.present(mail, animated: true)
    }
    
    func showEmailAlert(viewController: UIViewController) {
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
