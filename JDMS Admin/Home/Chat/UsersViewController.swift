//
//  UsersViewController.swift
//  JDMS Admin
//
//  Created by Moin Janjua on 29/12/2025.
//

import UIKit
import SideMenu
import NVActivityIndicatorView
import SDWebImage

class UsersViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nodataLb: UILabel!
    @IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!
    @IBOutlet weak var searchbar: UISearchBar!
    
    // Updated to hold Conversation objects instead of raw Users
    private var conversationList: [JDMSConversationData] = []
    private var filteredConversations: [JDMSConversationData] = [] // NEW: For search
    private let myId = UserDefaults.standard.integer(forKey: "userId")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchMyConversations()
    }
    
    private func setupUI()
    {
        tableView.delegate = self
        tableView.dataSource = self
        searchbar.delegate = self // Don't forget to set this!
        
        activityIndicatorView.type = .ballPulseSync
        activityIndicatorView.color = .systemGreen
        
        nodataLb.text = "No conversations found"
        nodataLb.isHidden = true
    }
    

    private func fetchMyConversations() {
        DispatchQueue.main.async {
            self.activityIndicatorView.startAnimating()
        }
            
            APIClient.shared.getConversations(for: myId) { [weak self] result in
                DispatchQueue.main.async {
                    self?.activityIndicatorView.stopAnimating()
                    switch result {
                    case .success(let chats):
                        self?.conversationList = chats
                        self?.filteredConversations = chats // Initialize filtered list
                        self?.updateUI()
                    case .failure(let error):
                        self?.showAlert(title: "Error", message: error.localizedDescription)
                    }
                }
            }
        }
    
    private func updateUI() {
            let hasData = !filteredConversations.isEmpty
            tableView.isHidden = !hasData
            nodataLb.isHidden = hasData
            tableView.reloadData()
        }

    private func navigateToChat(conversation: JDMSConversationData, otherUserName: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let chatVC = storyboard.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController else { return }
        
        chatVC.conversationId = conversation.id
        chatVC.chatTitle = otherUserName
        
        // Attempt to find the navigation controller from the window scene
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootNC = windowScene.windows.first?.rootViewController as? UINavigationController {
            rootNC.pushViewController(chatVC, animated: true)
        } else if let nav = self.navigationController {
            // Standard push fallback
            nav.pushViewController(chatVC, animated: true)
        } else {
            print("❌ Still no Navigation Controller found. Try 'Presenting' instead.")
            let nav = UINavigationController(rootViewController: chatVC)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true)
        }
    }

    @IBAction func openMenu(_ sender: UIButton) {
        let menu = storyboard?.instantiateViewController(withIdentifier:"SideMenuNavigation") as? SideMenuNavigationController
        menu?.leftSide = true
        menu?.settings = makeSettings()
        SideMenuManager.default.leftMenuNavigationController = menu
        present(menu!, animated: true, completion: nil)
    }
    
    @IBAction func addUsersbtn(_ sender: UIButton) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "AddUserViewController") as! AddUserViewController
        newViewController.modalPresentationStyle = .fullScreen
        newViewController.modalTransitionStyle = .crossDissolve
        self.present(newViewController, animated: true, completion: nil)
    }
}


extension UsersViewController {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredConversations = conversationList
        } else {
            filteredConversations = conversationList.filter { chat in
                // Logic: Search for the OTHER person's name in the conversation
                let otherParticipant = chat.participants.first(where: { $0.userId != myId })
                let name = otherParticipant?.userName ?? ""
                return name.lowercased().contains(searchText.lowercased())
            }
        }
        updateUI()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - TableView Methods
extension UsersViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredConversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? UserTableViewCell else {
            return UITableViewCell()
        }
        
        let chat = filteredConversations[indexPath.row]
        
        // 1. Participant Logic
        let otherParticipant = chat.participants.first(where: { $0.userId != myId })
        cell.usernamelb.text = otherParticipant?.userName ?? "Unknown"
        
        // 2. Last Message Logic
        if let lastMsg = chat.lastMessage {
            cell.lstmessagelb.text = lastMsg.text
        } else {
            cell.lstmessagelb.text = "No messages yet"
        }
        
        // 3. Time Logic (Fixed)
        if let dateString = chat.lastMessageAt {
            cell.messagetime.text = formatChatTime(dateString)
        } else {
            cell.messagetime.text = ""
        }
        
        // 4. Unread Count Logic
        if chat.unreadCount > 0 {
            cell.messageCountView.isHidden = false
            cell.messageCountlb.text = "\(chat.unreadCount)"
            // Make the view circular if it isn't already in Storyboard
            cell.messageCountView.layer.cornerRadius = cell.messageCountView.frame.height / 2
        } else {
            cell.messageCountView.isHidden = true
        }
        
        // 5. UI Tweaks
        cell.userImage.layer.cornerRadius = cell.userImage.frame.height / 2
        cell.userImage.clipsToBounds = true
        cell.userImage.backgroundColor = .systemGray5
        
        if let otherId = otherParticipant?.userId {
                // 1. Check if we already have the URL for this user in our local session
                // (You could also save this in a Dictionary [Int: String] to avoid API calls)
                APIClient.shared.getMemberProfile(id: otherId) { result in
                    switch result {
                    case .success(let fullImageUrl):
                        DispatchQueue.main.async {
                            cell.userImage.sd_setImage(with: URL(string: fullImageUrl),
                                                     placeholderImage: UIImage(named: "user 1"))
                        }
                    case .failure:
                        DispatchQueue.main.async {
                            cell.userImage.image = UIImage(named: "user 1")
                        }
                    }
                }
            }
            
            // UI Styling
            cell.userImage.layer.cornerRadius = cell.userImage.frame.height / 2
            cell.userImage.clipsToBounds = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let chat = filteredConversations[indexPath.row] // Use filtered list
        let otherParticipant = chat.participants.first(where: { $0.userId != myId })
        
        navigateToChat(conversation: chat, otherUserName: otherParticipant?.userName ?? "Chat")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    // Helper to format: "2026-03-14T00:49:55" -> "00:49"
    private func formatChatTime(_ dateStr: String) -> String {
        // 1. Create a DateFormatter that handles fractional seconds
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        // Try standard ISO8601 first, then fallback to fractional seconds format
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS", // Matches your DB: .7516994
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
            "yyyy-MM-dd'T'HH:mm:ssZ"
        ]
        
        var date: Date?
        for format in formats {
            dateFormatter.dateFormat = format
            if let d = dateFormatter.date(from: dateStr) {
                date = d
                break
            }
        }
        
        guard let finalDate = date else { return "" }
        
        // 2. Format for display (HH:mm)
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "HH:mm"
        return displayFormatter.string(from: finalDate)
    }
    
    private func loadImage(into imageView: UIImageView, urlString: String) {
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    imageView.image = image
                }
            }
        }.resume()
    }
    
}
