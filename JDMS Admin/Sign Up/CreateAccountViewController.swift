//
//  CreateAccountViewController.swift
//  JDMS Admin
//
//  Created by Moin Janjua on 27/12/2025.
//

import UIKit
import NVActivityIndicatorView

class CreateAccountViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
       
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        activityIndicatorView.type = .ballPulseSync
        activityIndicatorView.color = .systemGreen
        activityIndicatorView.isHidden = true // Keep it hidden until needed
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Actions
    @IBAction func signUpTapped(_ sender: UIButton) {
        // 1. Validation
        guard let name = nameTextField.text, !name.isEmpty,
              let email = emailTextField.text, !email.isEmpty,
              let phone = phoneTextField.text, !phone.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
            showAlert(title: "Error", message: "Please fill all fields")
            return
        }
        
        guard password == confirmPassword else {
            showAlert(title: "Error", message: "Passwords do not match")
            return
        }
        
        // 2. Prepare Request Model
        let requestData = RegisterRequest(
            fullName: name,
            email: email,
            phoneNumber: phone,
            password: password,
            confirmPassword: confirmPassword
        )
        
        // 3. Start Loading UI
        DispatchQueue.main.async {
            startLoading(view: self.activityIndicatorView)
        }
      
        
        // 4. Call API
        APIClient.shared.registerUser(params: requestData) { [weak self] result in
            guard let self = self else { return }
            
            // Stop Loading UI
           
            DispatchQueue.main.async {
                stopLoading(view: self.activityIndicatorView)
            }
            
            switch result {
            case .success(let response):
                if response.isSuccess {
                    // Success! Show message and maybe navigate to Login
                    self.showAlert(title: "Success", message: response.message ?? "Account created successfully!") {
                        self.navigateToLogin()
                    }
                } else {
                    // API returned an error (e.g., Email already exists)
                    let errorMessage = response.errors?.first?.description ?? response.message ?? "Registration failed."
                    self.showAlert(title: "Registration Failed", message: errorMessage)
                }
                
            case .failure(let error):
                // Networking error (No internet, timeout, etc.)
                self.showAlert(title: "Network Error", message: error.localizedDescription)
            }
        }
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        navigateToLogin()
    }
    
    // MARK: - Helpers
    
  
    private func navigateToLogin() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        newViewController.modalPresentationStyle = .fullScreen
        newViewController.modalTransitionStyle = .crossDissolve
        self.present(newViewController, animated: true, completion: nil)
    }
    
    // Enhanced showAlert with optional completion handler
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        self.present(alert, animated: true)
    }
}

