//
//  SystemAdminViewController.swift
//  JDMS Admin
//
//  Created by Moin Janjua on 29/12/2025.
//

import UIKit
import SideMenu
import NVActivityIndicatorView

class SystemAdminViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!
    @IBOutlet weak var roleView: UIView!
    @IBOutlet weak var roleDD: DropDown!
    @IBOutlet weak var userTF: UITextField!
    
    private var usersList: [JDMSUser] = []
    private var availableRoles: [JDMSUserRole] = []
    private var selectedUser: JDMSUser?
    private var selectedRoleId: Int?
    
    private let blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark) // You can use .light or .extraLight
        let view = UIVisualEffectView(effect: blurEffect)
        view.alpha = 0
        view.isHidden = true
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        roleView.isHidden = true
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(blurEffectView, belowSubview: roleView)
        setupTableView()
        setupLoader()
        setupDropDown()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUsers()
        fetchAllRoles() // Fetch roles once to populate the DropDown
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }

    private func setupLoader() {
        activityIndicatorView.type = .ballPulseSync
        activityIndicatorView.color = .systemGreen
    }

    private func setupDropDown() {
        roleDD.placeholder = "Select Role"
        
        // This closure handles the selection
        roleDD.didSelect { [weak self] selectedText, index, id in
            print("Selected Role: \(selectedText) at index: \(index)")
            self?.roleDD.text = selectedText
            guard let self = self else { return }
            
            // Match the selection to your availableRoles array to get the ID
            if index < self.availableRoles.count {
                self.selectedRoleId = self.availableRoles[index].id
            }
        }
    }

    // MARK: - API Calls
    private func fetchUsers() {
        self.activityIndicatorView.startAnimating()
        APIClient.shared.getAllUsers { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicatorView.stopAnimating()
                switch result {
                case .success(let fetchedUsers):
                    self?.usersList = fetchedUsers
                    self?.tableView.reloadData()
                case .failure(let error):
                    self?.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }

    private func fetchAllRoles() {
        APIClient.shared.getAllRoles { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let roles):
                    self?.availableRoles = roles
                    // Map roles to their names for the DropDown
                    let roleNames = roles.compactMap { $0.name }
                    self?.roleDD.optionArray = roleNames
                case .failure(let error):
                    print("Error fetching roles: \(error)")
                }
            }
        }
    }
    
    
    
    
    // MARK: - IBActions
    @IBAction func openMenu(_ sender: UIButton) {
        let menu = storyboard?.instantiateViewController(withIdentifier:"SideMenuNavigation") as? SideMenuNavigationController
        menu?.leftSide = true
        menu?.settings = makeSettings()
        SideMenuManager.default.leftMenuNavigationController = menu
        present(menu!, animated: true, completion: nil)
    }
    
//    @IBAction func updateRoleViewbtn(_ sender: UIButton) {
//        roleView.isHidden = !roleView.isHidden
//    }
    
    @IBAction func closeRoleViewbtn(_ sender: UIButton) {
        self.view.removeBlur()
        
        UIView.transition(with: roleView, duration: 0.3, options: .transitionCrossDissolve) {
            self.roleView.isHidden = true
        }
    }
    
    
    @IBAction func roleUpdatebtn(_ sender: UIButton) {
        guard let userId = selectedUser?.id, let roleId = selectedRoleId else {
            self.showAlert(title: "Selection Required", message: "Please select a user and a role first.")
            return
        }
        
        self.activityIndicatorView.startAnimating()
        APIClient.shared.assignRole(userId: userId, roleId: roleId) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicatorView.stopAnimating()
                switch result {
                case .success:
                    self?.roleView.isHidden = true
                    self?.clearRoleForm()
                    self?.fetchUsers() // Refresh list to show new role
                case .failure(let error):
                    self?.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }

    private func clearRoleForm() {
        selectedUser = nil
        selectedRoleId = nil
        userTF.text = ""
        roleDD.text = "Select Role"
    }
}

// MARK: - TableView Methods
extension SystemAdminViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? SystemTableViewCell else {
            return UITableViewCell()
        }
        
        let user = usersList[indexPath.row]
        cell.NameLb.text = "Full Name: \(user.name ?? "N/A")"
        cell.emailLb.text =   "Email: \(user.email ?? "No Email")"
        cell.phoneLb.text =  "Phone: \(user.phoneNumber ?? "No Phone")"
        cell.roleLb.text =  "Role: \(user.roles?.first?.name ?? "User")"
        
        if let dateString = user.created {
            cell.registeredLb.text = "Joined: \(formatDate(dateString))"
        } else {
            cell.registeredLb.text = ""
        }
        
        cell.onAssignRoleTap = { [weak self] in
                guard let self = self else { return }
                
            self.selectedUser = user
                self.userTF.text = user.name
                
                // Apply global blur to the main view
                self.view.addBlur(style: .dark)
                
                // Bring roleView to front so it's not blurred
                self.view.bringSubviewToFront(self.roleView)
                
                UIView.transition(with: self.roleView, duration: 0.3, options: .transitionCrossDissolve) {
                    self.roleView.isHidden = false
                }
            }
        
        
        return cell
    }
    
    // Select user to assign role
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = usersList[indexPath.row]
        self.selectedUser = user
        self.userTF.text = user.name
        self.roleView.isHidden = false // Show role update view automatically on selection
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 135
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let user = usersList[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completionHandler) in
            self?.confirmDelete(user: user, at: indexPath, completionHandler: completionHandler)
        }
        deleteAction.image = UIImage(systemName: "trash")

        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] (_, _, completionHandler) in
            self?.navigateToEditUser(user: user)
            completionHandler(true)
        }
        editAction.backgroundColor = .systemBlue
        editAction.image = UIImage(systemName: "pencil")
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }

    
    
    private func confirmDelete(user: JDMSUser, at indexPath: IndexPath, completionHandler: @escaping (Bool) -> Void)
    {

        let alert = UIAlertController(title: "Delete User", message: "Are you sure you want to delete \(user.name ?? "this user")?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                completionHandler(false)

            }))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
                    DispatchQueue.main.async {
                        self?.activityIndicatorView.startAnimating()
                        
                    }

                    DispatchQueue.main.async {
                        APIClient.shared.deleteUser(userId: user.id) { result in
                            self?.activityIndicatorView.stopAnimating()
                            switch result {
                            case .success:
                                self?.usersList.remove(at: indexPath.row)
                                self?.tableView.deleteRows(at: [indexPath], with: .fade)
                                completionHandler(true)
                            case .failure(let error):
                                self?.showAlert(title: "Error", message: error.localizedDescription)
                                completionHandler(false)

                            }
                        }
                    }
                }))

                present(alert, animated: true)
            }

        private func navigateToEditUser(user: JDMSUser) {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "SystenProfileViewController") as! SystenProfileViewController
            newViewController.userToEdit = user
            newViewController.modalPresentationStyle = .fullScreen
            newViewController.modalTransitionStyle = .crossDissolve
            self.present(newViewController, animated: true, completion: nil)
        }
    
    // Simple helper to format the API date: "2026-03-12T22:21:16" -> "Mar 12, 2026"
    private func formatDate(_ dateStr: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = formatter.date(from: dateStr) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            return displayFormatter.string(from: date)
        }
        return dateStr
    }
}
