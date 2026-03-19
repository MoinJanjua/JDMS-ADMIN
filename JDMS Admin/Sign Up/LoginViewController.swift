//
//  LoginViewController.swift
//  JDMS Admin
//
//  Created by Moin Janjua on 27/12/2025.
//


import UIKit
import NVActivityIndicatorView

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var StartBtn: UIButton!
    @IBOutlet weak var rememberbtn: UIButton!
    @IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!
    
    // Track the state of the remember button
    var isRemembered = false
    
    // Use system icons or your custom "checkMark" image
    let selectedImage = UIImage(named: "checkMark")
    let unselectedImage = UIImage(named: "uncheckMark") // Or nil for empty box

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadSavedCredentials()
        rememberbtn.setTitle("", for: .normal)
    }
    
    func setupUI() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        activityIndicatorView.type = .ballPulseSync
        activityIndicatorView.color = .systemGreen
        activityIndicatorView.isHidden = true
    }

    // MARK: - Remember Me Logic
    func loadSavedCredentials() {
        // Check if "Remember Me" was previously enabled
        isRemembered = UserDefaults.standard.bool(forKey: "isRememberMeEnabled")
        
        if isRemembered {
            emailTextField.text = UserDefaults.standard.string(forKey: "savedEmail")
            passwordTextField.text = UserDefaults.standard.string(forKey: "savedPassword")
            rememberbtn.setImage(selectedImage, for: .normal)
        } else {
            rememberbtn.setImage(unselectedImage, for: .normal)
        }
    }

    @IBAction func rememberbtbPressed(_ sender: UIButton) {
        isRemembered.toggle() // Switch between true/false
        
        if isRemembered {
            sender.setImage(selectedImage, for: .normal)
        } else {
            sender.setImage(nil, for: .normal)
            // Optional: Clear immediately if user unchecks it
            UserDefaults.standard.set(false, forKey: "isRememberMeEnabled")
            UserDefaults.standard.removeObject(forKey: "savedEmail")
            UserDefaults.standard.removeObject(forKey: "savedPassword")
        }
    }

    @IBAction func loginTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Error", message: "Please enter email and password")
            return
        }
        
        let loginRequest = LoginRequest(email: email, password: password)
        
        startLoading(view: self.activityIndicatorView)
        StartBtn.isEnabled = false
        
        APIClient.shared.loginUser(params: loginRequest) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                stopLoading(view: self.activityIndicatorView)
                self.StartBtn.isEnabled = true
                
                switch result {
                case .success(let response):
                    if response.isSuccess {
                        // --- REMEMBER ME LOGIC ---
                        if self.isRemembered {
                            UserDefaults.standard.set(true, forKey: "isRememberMeEnabled")
                            UserDefaults.standard.set(email, forKey: "savedEmail")
                            UserDefaults.standard.set(password, forKey: "savedPassword")
                        }
                        // -------------------------
                        
                        if let token = response.data?.token {
                            UserDefaults.standard.set(token, forKey: "userToken")
                            print("Token:", response.data?.token ?? "")
                            UserDefaults.standard.set(response.data?.id, forKey: "userId")
                            UserDefaults.standard.set(response.data?.name, forKey: "username")
                            
                            // Inside your Login logic after success
                            if let roles = response.data?.roles {
                                PermissionManager.shared.saveUserRoles(roles)
                            }
                        }
                        self.navigateToHome()
                    } else {
                        let errorMsg = response.errors?.first?.description ?? response.message ?? "Login Failed"
                        self.showAlert(title: "Login Error", message: errorMsg)
                    }
                case .failure(let error):
                    self.showAlert(title: "Network Error", message: error.localizedDescription)
                }
            }
        }
    }

    @objc func hideKeyboard() { view.endEditing(true) }

    private func navigateToHome() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        newViewController.modalPresentationStyle = .fullScreen
        newViewController.modalTransitionStyle = .crossDissolve
        self.present(newViewController, animated: true, completion: nil)
    }
    
    
    @IBAction func signupbtnTapped(_ sender: UIButton) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "CreateAccountViewController") as! CreateAccountViewController
        newViewController.modalPresentationStyle = .fullScreen
        newViewController.modalTransitionStyle = .crossDissolve
        self.present(newViewController, animated: true, completion: nil)
    }
    
    @IBAction func forgetbtnTapped(_ sender: UIButton) {
        
    }
}
