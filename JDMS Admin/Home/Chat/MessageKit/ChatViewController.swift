//
//  ChatViewController.swift
//  JDMS Admin
//
//  Created by Moin Janjua on 15/03/2026.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import NVActivityIndicatorView

class ChatViewController: MessagesViewController, ChatServiceDelegate {
 
    var conversationId: Int?
    var chatTitle: String?
    var chatMessages: [[String: Any]] = []
    
    private var messages: [JDMSChatMessage] = []
    private let currentUser = JDMSChatSender(senderId: "\(UserDefaults.standard.integer(forKey: "userId"))",
                                               displayName: "Me")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = chatTitle
        ChatService.shared.delegate = self
        ChatService.shared.start()
        setupUI()
        setupInputBar()
        // Connect delegates
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        
        if let id = conversationId {
                    ChatService.shared.joinChat(conversationId: id)
        }
        // UI Adjustments for MessageKit
        scrollsToLastItemOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
        // Inside viewDidLoad
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.textMessageSizeCalculator.messageLabelFont = .systemFont(ofSize: 16)
        }
        fetchMessages()
    }
    
    
    func didReceiveMessage(_ message: [String: Any]) {
            // This is called when the SignalR "ReceiveMessage" event triggers
            DispatchQueue.main.async {
                let newMessage = JDMSChatMessage(
                    text: message["messageText"] as? String ?? "",
                    senderId: message["senderId"] as? Int ?? 0,
                    senderName: message["senderName"] as? String ?? "User",
                    date: Date(), // Usually better to parse the 'createdAt' from payload
                    msgId: message["id"] as? Int ?? 0
                )
                
                // Append to your local array and refresh
                self.messages.append(newMessage)
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToLastItem(animated: true)
            }
        }

    func didUpdateTypingStatus(userId: Int, isTyping: Bool) {
        DispatchQueue.main.async {
            let isMe = userId == UserDefaults.standard.integer(forKey: "userId")
            
            if isTyping && !isMe {
                // Show typing status
                self.title = "Typing..."
            } else {
                // Restore original chat name
                self.title = self.chatTitle
            }
        }
    }
    
    
    private func setupUI() {
        // 1. Navigation Bar Styling
        navigationController?.navigationBar.tintColor = .white
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = primaryColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        // Ensures the back button arrow is white
        appearance.buttonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        // 2. Custom Back Button
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"),
                                       style: .plain,
                                       target: self,
                                       action: #selector(backAction))
        navigationItem.leftBarButtonItem = backButton

        // 3. CollectionView Background
        messagesCollectionView.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
    }

    @objc func backAction() {
        self.dismiss(animated: true)
    }
    
    
    private func setupInputBar() {
            // 3. Input Bar Styling
            messageInputBar.backgroundView.backgroundColor = .white
            messageInputBar.inputTextView.placeholder = "Type a message..."
            messageInputBar.inputTextView.layer.cornerRadius = 18
            messageInputBar.inputTextView.layer.borderWidth = 1
            messageInputBar.inputTextView.layer.borderColor = UIColor.systemGray4.cgColor
            messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
            messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 15, bottom: 8, right: 15)
            
            // 4. Send Button Styling
            messageInputBar.sendButton.setTitleColor(primaryColor, for: .normal)
            messageInputBar.sendButton.setTitleColor(primaryColor.withAlphaComponent(0.3), for: .highlighted)
            messageInputBar.sendButton.image = UIImage(systemName: "paperplane.fill")
            messageInputBar.sendButton.title = nil // Use icon instead of text
            messageInputBar.setRightStackViewWidthConstant(to: 40, animated: false)
        }
   
                                               
    func fetchMessages() {
        guard let id = conversationId else { return }
        
  
        
        APIClient.shared.getChatHistory(conversationId: id) { [weak self] result in
            DispatchQueue.main.async {
                
                
                switch result {
                case .success(let apiMessages):
                    // Map JDMSMessageData -> JDMSChatMessage
                    self?.messages = apiMessages.compactMap { data in
                        return JDMSChatMessage(
                            text: data.messageText ?? "", // Use the new property name here
                            senderId: data.senderId,
                            senderName: data.senderName ?? "User",
                            date: self?.parseDate(data.createdAt ?? "") ?? Date(),
                            msgId: data.id
                        )
                    }
                    self?.messagesCollectionView.reloadData()
                    self?.messagesCollectionView.scrollToLastItem(animated: false)
                    
                case .failure(let error):
                    print("Fetch Error: \(error.localizedDescription)")
                }
            }
        }
    }

    @IBAction func backbtnPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // Helper to parse the high-precision date from your DB
    private func parseDate(_ dateStr: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS" // Matches your DB format
        return dateFormatter.date(from: dateStr)
    }
}
                                               
// MARK: - Display & Layout Delegates
extension ChatViewController: MessagesDisplayDelegate, MessagesLayoutDelegate {
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        // Current user messages are Blue, Others are Gray
        return isFromCurrentSender(message: message) ? primaryColor : .white
    }
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
            return isFromCurrentSender(message: message) ? .white : .darkGray
        }

    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
            let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
            return .bubbleTail(corner, .curved)
        }
    
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.backgroundColor = .systemGray4
        avatarView.initials = String(message.sender.displayName.prefix(2)).uppercased()
        avatarView.layer.borderWidth = 1
        avatarView.layer.borderColor = UIColor.white.cgColor
    }}
                                               
// MARK: - Data Source
extension ChatViewController: MessagesDataSource {
    func currentSender() -> SenderType {
        return currentUser
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        // Show name every few messages or all of them
        return NSAttributedString(string: message.sender.displayName,
                                  attributes: [.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }
}

// MARK: - Input Bar Delegate
extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
            let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedText.isEmpty, let convId = conversationId else { return }
            
            // Clear input immediately for better UX
            inputBar.inputTextView.text = ""
            
            // Send via SignalR
            ChatService.shared.sendMessage(conversationId: convId, text: trimmedText)
        }

        // Use this specific MessageKit method for typing indicators
        func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
            guard let id = conversationId else { return }
            
            if !text.isEmpty {
                ChatService.shared.sendTypingIndicator(conversationId: id, isTyping: true)
                
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(stopTyping), object: nil)
                self.perform(#selector(stopTyping), with: nil, afterDelay: 2.0)
            }
        }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let id = conversationId {
            ChatService.shared.sendTypingIndicator(conversationId: id, isTyping: true)
            
            // Stop typing indicator after 2 seconds of no activity
            NSObject.cancelPreviousPerformRequests(withTarget: self)
            self.perform(#selector(stopTyping), with: nil, afterDelay: 2.0)
        }
        return true
    }

    @objc func stopTyping() {
        if let id = conversationId {
            ChatService.shared.sendTypingIndicator(conversationId: id, isTyping: false)
        }
    }
}
