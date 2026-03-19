//
//  sidebarMenuVC.swift
//  SourcePOS
//
//  Created by MacMini on 17/06/2021.
//

import UIKit
import Foundation
import SideMenu
import NVActivityIndicatorView

class SidebarMenuVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    @IBOutlet var viewContainer: UIView!
    @IBOutlet weak var tv:UITableView!
    @IBOutlet weak var userNsmeLb: UILabel!
    @IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!
    
    
    var firstName : String?
    var lastName : String?
    let uicolor = UIColor()
    
    var menuItems: [MenuItem] {
        // Basic items everyone can see
        var items = [
            MenuItem(title: "Dashboard", imageName: "Dashboard"),
            MenuItem(title: "Ameer-e-Jamat", imageName: "intro"),
            MenuItem(title: "Members", imageName: "Members"),
            MenuItem(title: "Chat", imageName: "Chat"),
            MenuItem(title: "Dawat & Tarbiyah", imageName: "article"),
            MenuItem(title: "Regions", imageName: "Regions"),
            MenuItem(title: "Ijtimaat", imageName: "Ijtimaat"),
            MenuItem(title: "Designations", imageName: "Designations"),
            MenuItem(title: "Voter", imageName: "id"),
            MenuItem(title: "Notifications", imageName: "Notifications"),
            MenuItem(title: "Feedback/Complaints", imageName: "compliants")
        ]
        
        // 🛡️ Admin & SuperAdmin ONLY items
        // Using your existing PermissionManager logic
        if PermissionManager.shared.canPerform(action: .addBanner) {
            items.append(MenuItem(title: "Banners", imageName: "bannerIcon"))
        }
        
        if PermissionManager.shared.canPerform(action: .manageRoles) {
            items.append(MenuItem(title: "System", imageName: "System"))
        }
        
        // Logout always at the end
        items.append(MenuItem(title: "Log Out", imageName: "logout"))
        
        return items
    }

    var defaultHighlightedCell: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicatorView.type = .ballPulseSync
        activityIndicatorView.color = .systemGreen
        activityIndicatorView.isHidden = true
        navigationController?.setNavigationBarHidden(true, animated: true)
        tv.tableFooterView = UIView()
        defaultHighlightedCell = UserDefaults.standard.integer(forKey: "SelectedMenuIndex")
        let useranme = UserDefaults.standard.value(forKey: "username") as? String ?? "User"
        userNsmeLb.text = useranme
        
    }
    
    
    private func showLogoutAlert() {

        let alert = UIAlertController(
            title: "Log Out",
            message: "Are you sure you want to log out?",
            preferredStyle: .alert
        )

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        let logoutAction = UIAlertAction(title: "Log Out", style: .destructive) { _ in
            self.performLogOut()
        }

        alert.addAction(cancelAction)
        alert.addAction(logoutAction)

        present(alert, animated: true)
    }
    
    
    func performLogOut()
    {
        DispatchQueue.main.async {
            startLoading(view: self.activityIndicatorView)
        }
            APIClient.shared.logoutUser { [weak self] result in
                guard let self = self else { return }
                
                // 3. Clear local storage regardless of API success/failure
                // This ensures the user isn't 'stuck' logged in if the server is down
                UserDefaults.standard.removeObject(forKey: "userToken")
                DispatchQueue.main.async {
                    stopLoading(view: self.activityIndicatorView)
                }
                switch result {
                case .success(let response):
                    if response.isSuccess {
                        print("Logout successful: \(response.message ?? "")")
                    }
                case .failure(let error):
                    self.handleAPIError(error)
                }
                
                // 4. Always return to Login Screen
                self.navigateToLogin()
            }
    }

    private func navigateToLogin() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyBoard.instantiateViewController(withIdentifier: "LoginViewController")
        
        // 1. Get the current Window
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
            // Fallback if window isn't found
            loginVC.modalPresentationStyle = .fullScreen
            self.present(loginVC, animated: true)
            return
        }
        
        // 2. Set the new root view controller
        window.rootViewController = loginVC
        
        // 3. Add a nice fade animation so it's not a jarring jump
        UIView.transition(with: window,
                          duration: 0.5,
                          options: .transitionCrossDissolve,
                          animations: nil,
                          completion: nil)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MenuViewCell

        let item = menuItems[indexPath.row]
        cell.ItemsLb.text = item.title
        cell.ItemsImages.image = UIImage(named: item.imageName)

        // 🔥 Selection UI
        if indexPath.row == defaultHighlightedCell {
            cell.contentView.backgroundColor = primaryColor.withAlphaComponent(0.15)
            cell.ItemsLb.textColor = primaryColor
            cell.ItemsImages.tintColor = primaryColor
        } else {
            cell.contentView.backgroundColor = .clear
            cell.ItemsLb.textColor = .label
            cell.ItemsImages.tintColor = .label
        }

        // Required for tintColor
        cell.ItemsImages.image = cell.ItemsImages.image?.withRenderingMode(.alwaysTemplate)

        return cell
    }

   
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        defaultHighlightedCell = indexPath.row
        tableView.reloadData()
        UserDefaults.standard.set(defaultHighlightedCell, forKey: "SelectedMenuIndex")
        let item = menuItems[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        // Handle logout separately
        if item.title == "Log Out" {
            tableView.deselectRow(at: indexPath, animated: true)
            showLogoutAlert()
            return
        }

        var destinationVC: UIViewController?

        switch item.title {

        case "Dashboard":
            destinationVC = storyboard.instantiateViewController(withIdentifier: "HomeViewController")
            
        case "Ameer-e-Jamat":
            destinationVC = storyboard.instantiateViewController(withIdentifier: "AmeerJamatViewController")

        case "Members":
            destinationVC = storyboard.instantiateViewController(withIdentifier: "MembersViewController")

        case "Chat":
            destinationVC = storyboard.instantiateViewController(withIdentifier: "UsersViewController")

        case "Dawat & Tarbiyah":
            destinationVC = storyboard.instantiateViewController(withIdentifier: "ArticleViewController")

        case "Regions":
            destinationVC = storyboard.instantiateViewController(withIdentifier: "RegionsViewController")

        case "Ijtimaat":
            destinationVC = storyboard.instantiateViewController(withIdentifier: "IjtimatViewController")

        case "Designations":
            destinationVC = storyboard.instantiateViewController(withIdentifier: "DesiginationViewController")
            
        case "Voter":
            destinationVC = storyboard.instantiateViewController(withIdentifier: "VoterListViewController")

        case "Notifications":
            destinationVC = storyboard.instantiateViewController(withIdentifier: "NotificationViewController")
//
//        case "Forms":
//            destinationVC = storyboard.instantiateViewController(withIdentifier: "FormsViewController")
            
        case "Feedback/Complaints":
            destinationVC = storyboard.instantiateViewController(withIdentifier: "FeedbackViewController")
            
        case "Banners":
            destinationVC = storyboard.instantiateViewController(withIdentifier: "BannerImageViewController")

        case "System":
            destinationVC = storyboard.instantiateViewController(withIdentifier: "SystemAdminViewController")

        default:
            break
        }

        guard let vc = destinationVC else { return }

            self.switchRootViewController(to: vc)
        
    }


    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    
    private func switchRootViewController(to vc: UIViewController) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }

        // This makes the new VC full screen automatically
        vc.modalPresentationStyle = .fullScreen
        
        // Add a smooth fade transition
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = vc
        }, completion: { _ in
            // Optional: Ensure the menu is fully dismissed from memory
            window.makeKeyAndVisible()
        })
    }
    
    
    @IBAction func prfoileButtonTapped(_ sender: UIButton) {
     
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        newViewController.modalPresentationStyle = .fullScreen
        newViewController.modalTransitionStyle = .crossDissolve
        self.present(newViewController, animated: true, completion: nil)
    }


}
