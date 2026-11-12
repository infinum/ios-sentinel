//
//  MailDataTests.swift
//  SentinelTests
//
//  Created by Nikola Simunko on 12.10.2026..
//

#if os(iOS)
import Foundation
import Testing
@testable import Sentinel

@Suite("Mail data")
struct MailDataTests {

    @Test("Missing subject and message become empty strings")
    func nilValuesBecomeEmpty() {
        let mail = MailData(
            subject: nil,
            message: nil,
            recipients: ["qa@example.com"]
        )

        #expect(mail.subject == "")
        #expect(mail.message == "")
    }

    @Test("Optional fields have sensible defaults")
    func defaults() {
        let mail = MailData(
            subject: "Subject",
            message: "Body",
            recipients: ["qa@example.com"]
        )

        #expect(mail.subject == "Subject")
        #expect(mail.message == "Body")
        #expect(!mail.isHTML)
        #expect(mail.attachments.isEmpty)
        #expect(mail.recipients == ["qa@example.com"])
        #expect(mail.ccRecipients.isEmpty)
        #expect(mail.bccRecipients.isEmpty)
    }

    @Test("Every value given is kept")
    func keepsValues() {
        let attachment = Attachment(
            data: Data("log".utf8),
            mimeType: "text/plain",
            fileName: "log.txt"
        )
        let mail = MailData(
            subject: "Subject",
            message: "<b>Body</b>",
            isHTML: true,
            attachments: [attachment],
            recipients: ["to@example.com"],
            ccRecipients: ["cc@example.com"],
            bccRecipients: ["bcc@example.com"]
        )

        #expect(mail.isHTML)
        #expect(mail.attachments.map(\.fileName) == ["log.txt"])
        #expect(mail.attachments.map(\.mimeType) == ["text/plain"])
        #expect(mail.ccRecipients == ["cc@example.com"])
        #expect(mail.bccRecipients == ["bcc@example.com"])
    }

    @Test("The tool keeps its name")
    func toolName() {
        let tool = EmailSenderTool(getter: { MailData(subject: nil, message: nil, recipients: []) })

        #expect(tool.name == "Email Sender")
    }
}
#endif
