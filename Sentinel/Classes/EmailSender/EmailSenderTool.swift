//
//  EmailSenderTool.swift
//  Sentinel
//
//  Created by Antonijo Bezmalinovic on 22.11.2023..
//

import SwiftUI
import MessageUI

/// Error representation of the EmailSender failing to show
public enum EmailSenderUnavailableError: Error {
    case unavailable
    case custom(title: String, message: String)
}

/// Tool which gives you the ability to easily integrate email sending with the MessageUI
public struct EmailSenderTool: Tool {

    // MARK: - Public properties
    
    public var name: String

    // MARK: - Private properties

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
    ///   - alertText: The message of the alert that appears if the device is not configured to send emails. Defaults to "Your device is not configured to send emails. Please set up an email account in Mail app or use another device."
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
    }
}

public extension EmailSenderTool {

    var content: any View {
        if EmailSenderView.canSendEmail() {
            EmailSenderView(mailData: getter())
        } else {
            EmailSenderErrorView(alertTitle: alertTitle, alertMessage: alertMessage)
        }
    }

}
