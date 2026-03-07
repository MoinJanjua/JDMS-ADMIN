//
//  ArticleViewController.swift
//  JDMS Admin
//
//  Created by Moin Janjua on 29/12/2025.
//

import UIKit
import SideMenu
import NVActivityIndicatorView

class DawatOTarbiahListViewController: UIViewController {
    
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var addbtn: UIButton!
    @IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!
    
    // 🚀 Updated to use the new DawatRecord model
    var articles: [DawatRecord] = []
    var currentPage = 1
    var isFetching = false
    var hasMoreData = true
    let pageSize = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tv.delegate = self
        tv.dataSource = self
        tv.separatorStyle = .none
        tv.rowHeight = 114 // Fixed height based on your requirement
        
        roundCorner(button: addbtn)
        addDropShadow(to: addbtn)
        
        setupActivityIndicator()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchDawatData(isRefresh: true)
    }
    
    func setupActivityIndicator() {
        activityIndicatorView.type = .ballPulseSync
        activityIndicatorView.color = .systemGreen
        activityIndicatorView.isHidden = true
    }
    
    func fetchDawatData(isRefresh: Bool = false) {
        guard !isFetching && (isRefresh || hasMoreData) else { return }
        
        isFetching = true
        if isRefresh {
            currentPage = 1
            articles.removeAll() // Clear list for refresh
        }
        
        DispatchQueue.main.async {
            self.activityIndicatorView.isHidden = false
            self.activityIndicatorView.startAnimating()
        }
        
        // 🚀 Using the new APIClient function with the POST body requirement
        APIClient.shared.fetchAllDawat(page: currentPage) { [weak self] result in
            DispatchQueue.main.async {
                self?.isFetching = false
                self?.activityIndicatorView.stopAnimating()
                self?.activityIndicatorView.isHidden = true
                
                switch result {
                case .success(let newItems):
                    // 1. Filter to only show active records (removes "soft deleted" items)
                    let activeItems = newItems.filter { $0.isActive == true }
                    
                    if isRefresh
                    {
                        self?.articles = activeItems
                    } else
                    {
                        self?.articles.append(contentsOf: activeItems)
                    }

                    // 2. Pagination Logic: Check the original count from server to decide if there's more data
                    if newItems.isEmpty {
                        self?.hasMoreData = false
                    } else {
                        self?.currentPage += 1
                        // If server returned a full page, assume there's more.
                        // Use newItems.count here, because the server sent them even if they are inactive.
                        self?.hasMoreData = newItems.count == self?.pageSize
                    }

                    DispatchQueue.main.async {
                        self?.tv.reloadData()
                    }
                    
                case .failure(let error):
                    self?.handleAPIError(error)
                    print("❌ Error fetching Dawat: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - ScrollView Logic for Pagination
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        if position > (tv.contentSize.height - 100 - scrollView.frame.size.height) {
            fetchDawatData(isRefresh: false)
        }
    }
    
    // MARK: - Actions
    @IBAction func openMenu(_ sender: UIButton) {
        let Menu = storyboard?.instantiateViewController(withIdentifier:"SideMenuNavigation") as? SideMenuNavigationController
        Menu?.leftSide = true
        Menu?.settings = makeSettings()
        SideMenuManager.default.leftMenuNavigationController = Menu
        present(Menu!, animated: true, completion: nil)
    }
    
   
    
    
    @IBAction func addmemberBtn(_ sender: UIButton) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "AddDawatoIslahViewController") as! AddDawatoIslahViewController
        newViewController.modalPresentationStyle = .fullScreen
        newViewController.modalTransitionStyle = .crossDissolve
        self.present(newViewController, animated: true, completion: nil)
    }
    
    
    private func confirmDelete(item: DawatRecord, at indexPath: IndexPath) {
        let alert = UIAlertController(title: "Delete Content", message: "Are you sure you want to delete '\(item.title ?? "")'?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            APIClient.shared.deleteDawat(id: item.id) { [weak self] result in
                switch result {
                case .success(let success):
                    if success {
                        self?.articles.remove(at: indexPath.row)
                        self?.tv.deleteRows(at: [indexPath], with: .fade)
                    }
                case .failure(let error):
                    print("Delete failed: \(error)")
                }
            }
        })
        present(alert, animated: true)
    }
    
    
}

// MARK: - TableView Extensions
extension DawatOTarbiahListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DawatIslahTableViewCell
        
        let item = articles[indexPath.row]
        
        // Populate the cell
        cell.title.text = item.title
        cell.title.font = .jameelNastaleeq(17)
        cell.category.text = item.category
        cell.descriptionlb.text = item.shortDescription
        cell.descriptionlb.font = .jameelNastaleeq(17)
        
        // 🚀 Professional Icon Switch: PDF vs Text
        if let pdf = item.pdfUrl, !pdf.isEmpty {
            cell.iconImage.image = UIImage(named: "file")
            cell.iconImage.tintColor = .systemRed
        } else {
            cell.iconImage.image = UIImage(systemName: "text.justify.left")
            cell.iconImage.tintColor = .white
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedItem = articles[indexPath.row]
        
        // Logic to decide which screen to open
        if let pdfPath = selectedItem.pdfUrl, !pdfPath.isEmpty {
            // Open PDF Screen
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let pdfVC = storyBoard.instantiateViewController(withIdentifier: "PDFViewController") as! PDFViewController
            pdfVC.modalPresentationStyle = .fullScreen
            pdfVC.str = selectedItem.title ?? "" // Or pass the full URL/Path
            pdfVC.pdfurl = pdfPath
            self.present(pdfVC, animated: true)
        } else {
            // Open Text Detail Screen (DawatDetailVC or similar)
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let pdfVC = storyBoard.instantiateViewController(withIdentifier: "PDFViewController") as! PDFViewController
            pdfVC.modalPresentationStyle = .fullScreen
            pdfVC.str = selectedItem.title ?? "" // Or pass the full URL/Path
            pdfVC.content_str = selectedItem.content ?? "No Records Found"
            self.present(pdfVC, animated: true)
        }
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let item = articles[indexPath.row]
        
        // 🗑 DELETE ACTION
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completionHandler) in
            self?.confirmDelete(item: item, at: indexPath)
            completionHandler(true)
        }
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .systemRed
        
        // ✏️ EDIT ACTION
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] (_, _, completionHandler) in
            self?.navigateToEdit(item: item)
            completionHandler(true)
        }
        editAction.image = UIImage(systemName: "pencil")
        editAction.backgroundColor = .systemBlue
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
    
    
    private func navigateToEdit(item: DawatRecord) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let editVC = storyBoard.instantiateViewController(withIdentifier: "AddDawatoIslahViewController") as! AddDawatoIslahViewController
        
        // Pass the existing data to your Add/Edit screen
        editVC.editItem = item
        editVC.isEditingMode = true
        
        editVC.modalPresentationStyle = .fullScreen
        self.present(editVC, animated: true)
    }
    
    
}
