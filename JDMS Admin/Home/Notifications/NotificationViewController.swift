//
//  NotificationViewController.swift
//  JDMS Admin
//
//  Created by Moin Janjua on 29/12/2025.
//

import UIKit
import SideMenu
import NVActivityIndicatorView

class NotificationViewController: UIViewController {

    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var addbtn: UIButton!
    @IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!

    // Changed from AppNotification to the API Model NotificationRecord
    var notificationList: [NotificationRecord] = []
    
    var currentPage = 1
    var isFetching = false
    var hasMoreData = true
    let pageSize = 50
    
    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        setupActivityIndicator()
        roundCorner(button: addbtn)
        
        // Initial Fetch from API
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchNotificationsData(isRefresh: true)
    }
    
    private func setupTableView() {
        tv.dataSource = self
        tv.delegate = self
        tv.tableFooterView = UIView()
        tv.separatorStyle = .none
        
        // Pull to Refresh
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tv.refreshControl = refreshControl
    }
    
    private func setupActivityIndicator() {
        activityIndicatorView.type = .ballRotate
        activityIndicatorView.color = primaryColor
        activityIndicatorView.padding = 0
        activityIndicatorView.isHidden = true
    }

    @objc private func refreshData() {
        fetchNotificationsData(isRefresh: true)
    }

    // MARK: - API Fetching
    private func fetchNotificationsData(isRefresh: Bool = false) {
        guard !isFetching else { return }
        
        if isRefresh {
            currentPage = 1
            hasMoreData = true
        }
        
        guard hasMoreData else { return }
        
        isFetching = true
        if isRefresh { refreshControl.beginRefreshing() }
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()

        APIClient.shared.fetchNotifications(pageNumber: currentPage, pageSize: pageSize) { [weak self] result in
            DispatchQueue.main.async {
                self?.isFetching = false
                self?.refreshControl.endRefreshing()
                self?.activityIndicatorView.stopAnimating()
                self?.activityIndicatorView.isHidden = true
                
                switch result {
                case .success(let response):
                    let newItems = response.data.data
                    
                    if isRefresh {
                        self?.notificationList = newItems
                    } else {
                        self?.notificationList.append(contentsOf: newItems)
                    }
                    
                    // Update Pagination state from response
                    self?.hasMoreData = response.data.paginationResponseDetails.hasNextPage
                    self?.currentPage += 1
                    
                    self?.tv.reloadData()
                    
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                    self?.handleAPIError(error)
                }
            }
        }
    }

    @IBAction func openMenu(_ sender: UIButton) {
        let Menu = storyboard?.instantiateViewController(withIdentifier:"SideMenuNavigation") as? SideMenuNavigationController
        Menu?.leftSide = true
        Menu?.settings = makeSettings()
        SideMenuManager.default.leftMenuNavigationController = Menu
        present(Menu!, animated: true, completion: nil)
    }
    
    @IBAction func AddNotifybtnTapped(_ sender: UIButton) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "AddNotificationsViewController") as! AddNotificationsViewController
        newViewController.modalPresentationStyle = .fullScreen
        newViewController.modalTransitionStyle = .crossDissolve
        self.present(newViewController, animated: true, completion: nil)
    }
}

// MARK: - TableView Methods
extension NotificationViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NotificationsTableViewCell

        let notify = notificationList[indexPath.row]
        
        // Populate UI
        cell.titleLabel.text = notify.title
        cell.messageLabel.text = notify.message
        
        // Formatting Date using your existing waterfall formatter
        if let dateStr = notify.notifyDate {
            cell.dateLabel.text = formatServerDate(dateStr)
        }

        // Apply Urdu fonts if needed
        cell.titleLabel.font = .jameelNastaleeqBold(17, isBold: true)
        cell.messageLabel.font = .jameelNastaleeq(17)
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notify = notificationList[indexPath.row]
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "NotificationsDetailsViewController") as! NotificationsDetailsViewController
        
        newViewController.message = notify.message ?? ""
        newViewController.titles = notify.title ?? ""
        newViewController.date = formatServerDate(notify.notifyDate ?? "")
        
        newViewController.modalPresentationStyle = .fullScreen
        newViewController.modalTransitionStyle = .crossDissolve
        self.present(newViewController, animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 86
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // 1. DELETE ACTION
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completionHandler) in
            guard let self = self else { return }
            let notification = self.notificationList[indexPath.row]
            
            self.activityIndicatorView.isHidden = false
            self.activityIndicatorView.startAnimating()
            
            APIClient.shared.deleteNotification(id: notification.id) { result in
                DispatchQueue.main.async {
                    self.activityIndicatorView.stopAnimating()
                    self.activityIndicatorView.isHidden = true
                    
                    switch result {
                    case .success(let success):
                        if success {
                            self.notificationList.remove(at: indexPath.row)
                            tableView.deleteRows(at: [indexPath], with: .automatic)
                        }
                    case .failure(let error):
                        self.handleAPIError(error)
                    }
                    completionHandler(true)
                }
            }
        }
        
        // 2. EDIT ACTION
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] (_, _, completionHandler) in
            guard let self = self else { return }
            let notifyToEdit = self.notificationList[indexPath.row]
            
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            if let editVC = storyBoard.instantiateViewController(withIdentifier: "AddNotificationsViewController") as? AddNotificationsViewController {
                
                // Assuming you add this variable to AddNotificationsViewController
                editVC.existingNotification = notifyToEdit
                
                editVC.modalPresentationStyle = .fullScreen
                editVC.modalTransitionStyle = .crossDissolve
                self.present(editVC, animated: true)
            }
            completionHandler(true)
        }
        
        editAction.backgroundColor = .systemBlue
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
    
    // Pagination trigger
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.height * 1.5 {
            if !isFetching && hasMoreData {
                fetchNotificationsData()
            }
        }
    }
}
