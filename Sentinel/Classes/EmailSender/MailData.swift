//
//  MailData.swift
//  Sentinel
//
//  Created by Antonijo Bezmalinovic on 22.11.2023..
//

import Foundation

public struct MailData {
    
    struct Attachment {
        let data: Data?
        let mimeType: String
        let fileName: String
    }
    
    let subject: String
    let message: String
    let isHTML: Bool
    let attachments: [Attachment]
    let toRecipients: [String]
    let ccRecipients: [String]
    let bccRecipients: [String]
    
    init(
        subject: String,
        message: String,
        isHTML: Bool = false,
        attachments: [Attachment] = [],
        toRecipients: [String],
        ccRecipients: [String] = [],
        bccRecipients: [String] = []
    ) {
        self.subject = subject
        self.message = message
        self.isHTML = isHTML
        self.attachments = attachments
        self.toRecipients = toRecipients
        self.ccRecipients = ccRecipients
        self.bccRecipients = bccRecipients
    }
}
