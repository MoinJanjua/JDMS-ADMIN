//
//  Untitled.swift
//  JDMS Admin
//
//  Created by Moin Janjua on 15/03/2026.
//

import Foundation
import MessageKit

// 1. Define the Sender
struct JDMSChatSender: SenderType {
    var senderId: String
    var displayName: String
}

// 2. Define the Message Model
struct JDMSChatMessage: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    
    // Custom helper to map from your API Response
    init(text: String, senderId: Int, senderName: String, date: Date, msgId: Int) {
        self.sender = JDMSChatSender(senderId: "\(senderId)", displayName: senderName)
        self.messageId = "\(msgId)"
        self.sentDate = date
        self.kind = .text(text)
    }
}
