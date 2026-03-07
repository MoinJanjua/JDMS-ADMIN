//
//  ProfileViewController.swift
//  JDMS Admin
//
//  Created by Moin Janjua on 02/03/2026.
//

import UIKit
import NVActivityIndicatorView

class ProfileViewController: UIViewController {

    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var usernamelb: UILabel!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var phoneTF: UITextField! // Make sure this is in your UI
    @IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!
    
    var userId: Int = 35 // You should get this from your Login Response/UserDefaults

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
       
    }
    
    private func setupUI() {
        activityIndicatorView.type = .ballRotate
        activityIndicatorView.color = primaryColor
        activityIndicatorView.isHidden = true
        
        if let userIdString = UserDefaults.standard.string(forKey: "userId"),
           let convertedId = Int(userIdString) {
            self.userId = convertedId
        } else {
            // If it was already an Int
            self.userId = UserDefaults.standard.integer(forKey: "userId")
        }
        loadProfile()
    }

    private func loadProfile() {
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
        
        APIClient.shared.fetchUserProfile(userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicatorView.stopAnimating()
                self?.activityIndicatorView.isHidden = true
                
                switch result {
                case .success(let response):
                    self?.nameTF.text = response.data.name
                    self?.emailTF.text = response.data.email
                    self?.usernamelb.text =  response.data.name
                    // Note: Phone number might need to be fetched/stored separately
                    // if it's not in the GET response but required for PATCH
                case .failure(let error):
                    self?.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }

    @IBAction func updateTapped(_ sender: UIButton) {
        guard let name = nameTF.text, !name.isEmpty,
              let email = emailTF.text, !email.isEmpty else {
            showAlert(title: "Validation", message: "Name and Email are required.")
            return
        }

        let updateData = UserUpdateRequest(
            fullName: name,
            email: email,
            phoneNumber: phoneTF.text ?? ""
        )

        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()

        APIClient.shared.updateUserProfile(userId: userId, params: updateData) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicatorView.stopAnimating()
                self?.activityIndicatorView.isHidden = true
                
                switch result {
                case .success(let success):
                    if success {
                        self?.showAlert(title: "Success", message: "Profile updated successfully!")
                    }
                case .failure(let error):
                    self?.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    
    @IBAction func backbtnTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}
