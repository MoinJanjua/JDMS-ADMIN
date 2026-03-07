//
//  AmeerJamatViewController.swift
//  JDMS Admin
//
//  Created by Moin Janjua on 19/02/2026.
//

import UIKit
import NVActivityIndicatorView
import SideMenu

class AmeerJamatViewController: UIViewController {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var messaegView: UITextView!
    @IBOutlet weak var adbtn: UIButton!
    @IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    // Replace this ID with the actual ID passed from your previous screen
    var recordID: Int64 = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let btn = adbtn
        {
            roundCorner(button: btn)
        }
        
      
    }
    override func viewWillAppear(_ animated: Bool) {
        setupUI()
        
        // Setup Loader
        activityIndicatorView.type = .ballPulseSync
        activityIndicatorView.color = .systemGreen
        activityIndicatorView.isHidden = true
        
        // Load data immediately on open
        fetchRecord()
    }
    
    func setupUI() {
        messaegView.layer.cornerRadius = 8
        messaegView.layer.borderWidth = 1
        messaegView.layer.borderColor = UIColor.systemGray4.cgColor
        
        userImage.layer.cornerRadius = 10
        userImage.clipsToBounds = true
        userImage.contentMode = .scaleAspectFill
        userImage.backgroundColor = UIColor.systemGray5
        
        indicatorView.isHidden = true
    }
    
    
    @IBAction func openMenu(_ sender: UIButton) {
        let Menu = storyboard?.instantiateViewController(withIdentifier:"SideMenuNavigation") as? SideMenuNavigationController
        Menu?.leftSide = true
        Menu?.settings = makeSettings()
        SideMenuManager.default.leftMenuNavigationController = Menu
        present(Menu!, animated: true, completion: nil)
        
    }
    
    @IBAction func addbtnTapped(_ sender: UIButton) {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "AmeerJamatIntroViewController") as! AmeerJamatIntroViewController
        newViewController.modalPresentationStyle = .fullScreen
        newViewController.modalTransitionStyle = .crossDissolve
        self.present(newViewController, animated: true, completion: nil)
        
    }
    
    
    // MARK: - API Calls
    
    private func fetchRecord() {
        DispatchQueue.main.async {
            self.startLoading()
        }
        
        DispatchQueue.main.async {
            
            APIClient.shared.getAmeerMessage(id: self.recordID) { [weak self] result in
                guard let self = self else { return }
                self.stopLoading()
                
                switch result {
                case .success(let record):
                    self.messaegView.text = record.messageText
                    
                    if let imagePath = record.imageUrl, !imagePath.isEmpty {
                        // Construct the full URL by adding your base domain
                        let fullURLString = APIClient.shared.baseURL + imagePath
                        
                        if let url = URL(string: fullURLString) {
                            self.loadImage(from: url)
                        }
                    }
                    
                case .failure(let error):
                    self.handleAPIError(error) // Using our session handler!
                }
            }
        }
    }
    
    
    
    @IBAction func deletebtnTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Confirm Delete", message: "Are you sure you want to delete this record?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.performDelete()
        }))
        
        present(alert, animated: true)
    }
    
    private func performDelete() {
        self.startLoading()
        
        APIClient.shared.deleteAmeerMessage(id: recordID) { [weak self] result in
            guard let self = self else { return }
            self.stopLoading()
            
            switch result {
            case .success:
                self.showAlert(title: "Deleted", message: "Record deleted successfully.") {
                    self.navigationController?.popViewController(animated: true)
                }
            case .failure(let error):
                self.handleAPIError(error)
            }
        }
    }

    // MARK: - Helpers
    
    private func startLoading() {
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
        view.isUserInteractionEnabled = false // Prevent interaction while loading
    }
    
    private func stopLoading() {
        activityIndicatorView.stopAnimating()
        activityIndicatorView.isHidden = true
        view.isUserInteractionEnabled = true
    }
    
    private func loadImage(from url: URL) {
        // 1. Set a placeholder while loading
        indicatorView.isHidden = false
        DispatchQueue.main.async {
            self.indicatorView.startAnimating()
            self.userImage.image = UIImage(named: "placeholder_profile")
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            // Check if data exists and is actually an image
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.userImage.image = image
                    self?.indicatorView.isHidden = true
                    self?.indicatorView.stopAnimating()
                }
            } else {
                print("❌ Image Load Failed: \(error?.localizedDescription ?? "Invalid Data")")
                self?.indicatorView.isHidden = true
                self?.indicatorView.stopAnimating()
            }
        }.resume()
    }
    
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
}
