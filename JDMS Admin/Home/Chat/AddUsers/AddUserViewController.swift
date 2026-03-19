//
//  AddUserViewController.swift
//  JDMS Admin
//
//  Created by Moin Janjua on 17/03/2026.
//

import UIKit
import SideMenu
import NVActivityIndicatorView
import SDWebImage

class AddUserViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nodataLb: UILabel!
    @IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!
    @IBOutlet weak var searchbar: UISearchBar!
    
    private var usersList: [JDMSUser] = []
    private var filteredUsers: [JDMSUser] = [] // For search results
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchUsers()
    }
    
    private func setupUI() {
        tableView.delegate = self
        tableView.dataSource = self
        searchbar.delegate = self
        
        // Initial state of No Data Label
        nodataLb.text = "No users found"
        nodataLb.isHidden = true
    }

    private func fetchUsers() {
        self.activityIndicatorView.startAnimating()
        APIClient.shared.getAllUsers { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicatorView.stopAnimating()
                switch result {
                case .success(let fetchedUsers):
                    self?.usersList = fetchedUsers
                    self?.filteredUsers = fetchedUsers // Initialize filtered list
                    self?.updateUI()
                case .failure(let error):
                    self?.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    // Updates Table visibility and No Data label
    private func updateUI() {
        let hasData = !filteredUsers.isEmpty
        tableView.isHidden = !hasData
        nodataLb.isHidden = hasData
        tableView.reloadData()
    }
}

// MARK: - Search Bar Delegate
extension AddUserViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredUsers = usersList
        } else {
            filteredUsers = usersList.filter { user in
                // Search by name or email (case-insensitive)
                let nameMatch = user.name?.lowercased().contains(searchText.lowercased()) ?? false
                let emailMatch = user.email?.lowercased().contains(searchText.lowercased()) ?? false
                return nameMatch || emailMatch
            }
        }
        updateUI()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    @IBAction func backbtnPressed(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}

// MARK: - TableView Delegate & DataSource
extension AddUserViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? AddUserTableViewCell else {
            return UITableViewCell()
        }
        
        let user = self.filteredUsers[indexPath.row]
        cell.usernamelb.text = user.name
        
        // Handle image loading
//        if let urlStr = user., let url = URL(string: urlStr) {
//            cell.userImage.sd_setImage(with: url, placeholderImage: UIImage(named: "userPlaceholder"))
//        }
        
        // Styling
        cell.userImage.layer.cornerRadius = cell.userImage.frame.height / 2
        cell.userImage.clipsToBounds = true
        
        // Add Chat Button logic
        cell.onAddTap = { [weak self] in
            self?.handleAddUserForChat(user: user)
        }
        
        return cell
    }
    
    private func handleAddUserForChat(user: JDMSUser) {
        let myId = UserDefaults.standard.integer(forKey: "userId") // Your ID (e.g., 42)
        let targetId = user.id // The ID of the user you tapped
        
        self.activityIndicatorView.startAnimating()
        
        APIClient.shared.createDirectConversation(user1Id: myId, user2Id: targetId) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicatorView.stopAnimating()
                
                switch result {
                case .success(let conversationId):
                    // Success! Now navigate to the chat screen
                    self?.navigateToChat(conversationId: conversationId, userName: user.name ?? "Chat")
                    
                case .failure(let error):
                    self?.showAlert(title: "Connection Error", message: error.localizedDescription)
                }
            }
        }
    }

    private func navigateToChat(conversationId: Int, userName: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let chatVC = storyboard.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController else { return }
        
        chatVC.conversationId = conversationId
        chatVC.chatTitle = userName
        
        // Since this VC was likely presented modally, we dismiss it and then push the chat,
        // or push it directly if wrapped in a Nav Controller.
        if let nav = self.navigationController {
            nav.pushViewController(chatVC, animated: true)
        } else {
            // Fallback: If no nav, dismiss this picker and tell the parent to open the chat
            self.dismiss(animated: true) {
                // Use a notification or delegate to tell the main UsersViewController to open the chat
                NotificationCenter.default.post(name: NSNotification.Name("OpenChat"), object: nil, userInfo: ["id": conversationId, "name": userName])
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}
