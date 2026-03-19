//
//  SystenProfileViewController.swift
//  JDMS Admin
//
//  Created by Moin Janjua on 13/03/2026.
//

import UIKit
import NVActivityIndicatorView

class SystenProfileViewController: UIViewController {

    @IBOutlet weak var FullNameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var phoneTF: UITextField! // Make sure this is in your UI
    @IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!
    var userToEdit: JDMSUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicatorView.type = .ballRotate
        activityIndicatorView.color = primaryColor
        setupFields()
    }
    
    
    private func setupFields() {
            if let user = userToEdit {
                FullNameTF.text = user.name
                emailTF.text = user.email
                phoneTF.text = user.phoneNumber
            }
        }
    
    @IBAction func updateTapped(_ sender: UIButton) {
        guard let user = userToEdit,
              let name = FullNameTF.text, !name.isEmpty,
              let email = emailTF.text, !email.isEmpty,
              let phone = phoneTF.text, !phone.isEmpty else {
            // Show alert for missing fields if necessary
            return
        }
        
        guard let phone = phoneTF.text, phone.count >= 10 else {
                showAlert(title: "Invalid Phone", message: "Please enter a valid phone number.")
                return
            }
        
        
        activityIndicatorView.startAnimating()
        sender.isEnabled = false
        
        APIClient.shared.patchUserDetails(userId: user.id, fullName: name, email: email, phone: phone) { [weak self] result in
            self?.activityIndicatorView.stopAnimating()
            sender.isEnabled = true
            
            switch result {
            case .success:
                let alert = UIAlertController(title: "Updated", message: "User profile has been updated successfully.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                    // Dismiss and ideally tell the previous screen to refresh
                    self?.dismiss(animated: true)
                }))
                self?.present(alert, animated: true)
                
            case .failure(let error):
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            }
        }
    }
    
    
    @IBAction func backbtnTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}
