//
//  ChatService.swift
//  JDMS Admin
//
//  Created by Moin Janjua on 17/03/2026.
//

import Foundation
import SwiftSignalRClient

protocol ChatServiceDelegate: AnyObject {
    func didReceiveMessage(_ message: [String: Any])
    func didUpdateTypingStatus(userId: Int, isTyping: Bool)
}

class ChatService {
    static let shared = ChatService()
    private var connection: HubConnection?
    private var isConnected = false // Track state here
    weak var delegate: ChatServiceDelegate?
    var pendingConversationId: Int?
    
    private let myId = UserDefaults.standard.integer(forKey: "userId")
    private let token = UserDefaults.standard.string(forKey: "userToken") ?? ""
    
    func start() {
        let url = URL(string: "\(APIClient.shared.baseURL)/chathub")!
        
        // 1. Initialize Connection with Bearer Token
        connection = HubConnectionBuilder(url: url)
            .withHttpConnectionOptions { options in
                options.accessTokenProvider = { self.token }
            }
            .withAutoReconnect()
            .build()
        
        // 2. Listen for "ReceiveMessage" Event
        connection?.on(method: "ReceiveMessage") { (id: Int, convId: Int, senderId: Int, name: String, text: String, type: String, date: String) in
            let msgPayload: [String: Any] = [
                "id": id,
                "conversationId": convId,
                "senderId": senderId,
                "senderName": name,
                "messageText": text,
                "messageType": type,
                "createdAt": date
            ]
            self.delegate?.didReceiveMessage(msgPayload)
        }
        
        // 3. Start Connection
        connection?.start()
        
        connection?.delegate = self
    }
    
    // MARK: - Actions from your Table
    
    func registerOnline() {
        connection?.invoke(method: "RegisterUserOnline", myId) { error in
            if let error = error { print("Register Error: \(error)") }
        }
    }
    
    func joinChat(conversationId: Int) {
        if isConnected {
            print("🚀 Joining Conversation: \(conversationId)")
            connection?.invoke(method: "JoinConversation", conversationId) { error in
                if let error = error { print("❌ Join Error: \(error)") }
            }
        } else {
            // Store it to join as soon as connectionDidOpen triggers
            self.pendingConversationId = conversationId
            print("⏳ Connection not ready. Queueing join for ID: \(conversationId)")
        }
    }
    
    func sendMessage(conversationId: Int, text: String) {
        let currentId = UserDefaults.standard.integer(forKey: "userId")
        
        // Create the DTO
        let dto = MessageDto(
            ConversationId: conversationId,
            SenderId: currentId,
            MessageText: text
        )
        
        print("🚀 Mirroring Web Payload: \(dto)")

        // Pass the DTO as the ONLY argument in the list
        connection?.invoke(method: "SendMessage", dto) { error in
            if let error = error {
                print("❌ DTO Send Error: \(error)")
                
                // If it still fails, try lowercase method name
                // self.connection?.invoke(method: "sendMessage", dto) { ... }
            } else {
                print("✅ SUCCESS! Message sent via DTO.")
            }
        }
    }
    
    
    
    func sendTypingIndicator(conversationId: Int, isTyping: Bool) {
        connection?.invoke(method: "UserTyping", conversationId, myId, isTyping) { _ in }
    }
}

extension ChatService: HubConnectionDelegate {
    func connectionDidClose(error: (any Error)?) {
        isConnected = false
        print("❌ Connection DidClose Failed: \(String(describing: error))")
    }
    
    func connectionDidOpen(hubConnection: HubConnection) {
            print("✅ SignalR Connected")
            isConnected = true
            
            // 1. Register user
            let myId = UserDefaults.standard.integer(forKey: "userId")
            connection?.invoke(method: "RegisterUserOnline", myId) { _ in }
            
            // 2. Join pending chat
            if let id = pendingConversationId {
                joinChat(conversationId: id)
                pendingConversationId = nil
            }
        }
    
    func connectionDidFailToOpen(error: Error) {
        print("❌ SignalR Connection Failed: \(error)")
        isConnected = false
    }
}


struct MessageDto: Encodable {
    let ConversationId: Int
    let SenderId: Int
    let MessageText: String
    let MessageType: String = "Text" // Matches your ReceiveMessage "Type"
}
