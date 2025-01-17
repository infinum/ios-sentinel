//
//  MailData.swift
//  Sentinel
//
//  Created by Antonijo Bezmalinovic on 22.11.2023..
//

import Foundation

/// Item which represents the mail attachment
public struct Attachment {
    
    let data: Data
    let mimeType: String
    let fileName: String
    
    public init(
        data: Data,
        mimeType: String,
        fileName: String
    ) {
        self.data = data
        self.mimeType = mimeType
        self.fileName = fileName
    }
}

/// Data structure that holds all the information needed to send an email.
public struct MailData {
    
    let subject: String
    let message: String
    let isHTML: Bool
    let attachments: [Attachment]
    let recipients: [String]
    let ccRecipients: [String]
    let bccRecipients: [String]
    
    public init(
        subject: String?,
        message: String?,
        isHTML: Bool = false,
        attachments: [Attachment] = [],
        recipients: [String],
        ccRecipients: [String] = [],
        bccRecipients: [String] = []
    ) {
        self.subject = subject ?? ""
        self.message = message ?? ""
        self.isHTML = isHTML
        self.attachments = attachments
        self.recipients = recipients
        self.ccRecipients = ccRecipients
        self.bccRecipients = bccRecipients
    }
}
