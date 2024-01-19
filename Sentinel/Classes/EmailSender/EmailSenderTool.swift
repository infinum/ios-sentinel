//
//  EmailSenderTool.swift
//  Sentinel
//
//  Created by Antonijo Bezmalinovic on 22.11.2023..
//

import Foundation
import MessageUI

public enum EmailSenderUnavailableError: Error {
    case unavailable
    case custom(title: String, message: String)
}

@objcMembers
public final class EmailSenderTool: NSObject, Tool {

    // MARK: - Public properties -
    
    public var name: String

    // MARK: - Private properties -

    private let getter: () -> (MailData)

    private var alertTitle: String
    private var alertMessage: String

    /// Initializes an instance of EmailSender with the provided configurations.
    ///
    /// The email data (subject, body, attachment, etc.) is provided by a 'getter' callback. This callback should be implemented during the Sentinel initialization step. For example, you can set up the Sentinel with an EmailSenderTool in the Sentinel's configuration:
    ///
    /// ```
    /// class SentinelInitializer {
    ///     let configuration = Sentinel.Configuration(
    ///         trigger: Triggers.shake,
    ///         sourceScreenProvider: SourceScreenProviders.default,
    ///         tools: [
    ///             // other tools...
    ///             EmailSenderTool {
    ///                 return DomeProvider.composeMail()
    ///             },
    ///             // other tools...
    ///         ]
    ///     )
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - getter: A callback function that returns `MailData` for the email to be sent.
    ///   - name: The name for the Email Sender tool. Defaults to "Email Sender".
    ///   - alertTitle: The title of the alert that appears if the device is not configured to send emails. Defaults to "Email Not Available".
    ///   - alertMessage: The message of the alert that appears if the device is not configured to send emails. Defaults to "Your device is not configured to send emails. Please set up an email account in Mail app or use another device."
    ///
    /// - Note: Ensure that the device is configured to send emails, or the user will be prompted with the specified alert.
    public init(
        getter: @escaping () -> (MailData),
        name: String = "Email Sender",
        alertText: EmailSenderUnavailableError = .unavailable
    ) {
        self.getter = getter
        self.name = name
        
        switch alertText {
        case .unavailable:
            self.alertTitle = "Email Not Available"
            self.alertMessage = "Your device is not configured to send emails. Please set up an email account in Mail app or use another device."
        case .custom(let title, let message):
            self.alertTitle = title
            self.alertMessage = message
        }

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
        showSendEmail(from: viewController)
    }
            
    func showSendEmail(from viewController: UIViewController) {
        
        let mailData = getter()
        
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self
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
        
        viewController.present(mail, animated: true)
    }
    
    func showEmailAlert(from viewController: UIViewController) {
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
