//
//  BannerImageViewController.swift
//  JDMS Admin
//
//  Created by Moin Janjua on 16/03/2026.
//

import UIKit
import PhotosUI
import NVActivityIndicatorView
import SideMenu
import SDWebImage // Ensure this is installed via CocoaPods or Swift Package Manager

class BannerImageViewController: UIViewController {

    @IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!
    @IBOutlet weak var tableview: UITableView!
    
    // Holds the images fetched from the API
    var bannersList: [BannerImage] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        activityIndicatorView.type = .ballPulse
        fetchBanners()
    }
    
    private func setupTableView() {
        tableview.delegate = self
        tableview.dataSource = self
        // This removes empty separators at the bottom
        tableview.tableFooterView = UIView()
    }
    
    func fetchBanners() {
        DispatchQueue.main.async {
            self.activityIndicatorView.startAnimating()
        }
        
        APIClient.shared.getBannerImages { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicatorView.stopAnimating()
                
                switch result {
                case .success(let banners):
                    // Sort order-wise based on displayOrder if it's a number string
                    self?.bannersList = banners.sorted {
                        Int($0.displayOrder ?? "0") ?? 0 < Int($1.displayOrder ?? "0") ?? 0
                    }
                    self?.tableview.reloadData()
                    print("Successfully loaded \(banners.count) banners")
                    
                case .failure(let error):
                    self?.handleAPIError(error)
                }
            }
        }
    }
    
    @IBAction func addImagesbtnPressed(_ sender: UIButton) {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 0
        configuration.filter = .images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @IBAction func openMenu(_ sender: UIButton) {
        let Menu = storyboard?.instantiateViewController(withIdentifier:"SideMenuNavigation") as? SideMenuNavigationController
        Menu?.leftSide = true
        Menu?.settings = makeSettings()
        SideMenuManager.default.leftMenuNavigationController = Menu
        present(Menu!, animated: true, completion: nil)
    }
}

// MARK: - UITableView DataSource & Delegate
extension BannerImageViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bannersList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? BannerImageTableViewCell else {
            return UITableViewCell()
        }
        
        let banner = bannersList[indexPath.row]
        
        // Use the full URL helper we created in the BannerImage struct
        let fullURL = "\(APIClient.shared.baseURL)\(banner.imageUrl)"
        
        // Professional image loading with a placeholder
        cell.bannerImage.sd_setImage(with: URL(string: fullURL), placeholderImage: UIImage(named: "placeholder"))
        
        // Optional: Professional styling for the image
        cell.bannerImage.layer.cornerRadius = 8
        cell.bannerImage.contentMode = .scaleAspectFill
        
        cell.onDeleteTapped = { [weak self] in
            self?.confirmDeletion(at: indexPath)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200 // Adjust based on your UI design
    }
    
    
    private func confirmDeletion(at indexPath: IndexPath) {
            let alert = UIAlertController(title: "Delete Banner",
                                          message: "Are you sure you want to remove this image?",
                                          preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                self.performDelete(at: indexPath)
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            // For iPad support
            if let popoverController = alert.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
            
            present(alert, animated: true)
        }
    
    
    private func performDelete(at indexPath: IndexPath)
    {
            let bannerId = bannersList[indexPath.row].id
            
            self.activityIndicatorView.startAnimating()
            self.activityIndicatorView.isHidden = false
            
            APIClient.shared.deleteBannerImage(id: bannerId) { [weak self] result in
                DispatchQueue.main.async {
                    self?.activityIndicatorView.stopAnimating()
                    self?.activityIndicatorView.isHidden = true
                    
                    switch result {
                    case .success(let isSuccess):
                        if isSuccess {
                            // 1. Update Data Source
                            self?.bannersList.remove(at: indexPath.row)
                            // 2. Animate row removal
                            self?.tableview.deleteRows(at: [indexPath], with: .fade)
                            print("✅ Banner \(bannerId) deleted")
                    }
                    case .failure(let error):
                        self?.handleAPIError(error)
                }
            }
        }
    }
}

// MARK: - PHPickerViewControllerDelegate
extension BannerImageViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        let itemProviders = results.map(\.itemProvider)
        var selectedImages: [UIImage] = []
        let group = DispatchGroup()
        
        for provider in itemProviders {
            if provider.canLoadObject(ofClass: UIImage.self) {
                group.enter()
                provider.loadObject(ofClass: UIImage.self) { (image, error) in
                    if let image = image as? UIImage {
                        selectedImages.append(image)
                    }
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            if !selectedImages.isEmpty {
                self.activityIndicatorView.startAnimating()
                
                APIClient.shared.uploadBannerImages(images: selectedImages) { [weak self] result in
                    DispatchQueue.main.async {
                        self?.activityIndicatorView.stopAnimating()
                        
                        switch result {
                        case .success:
                            print("Banners uploaded successfully!")
                            self?.fetchBanners() // Refresh the list to show new images
                        case .failure(let error):
                            self?.handleAPIError(error)
                        }
                    }
                }
            }
        }
    }
}
