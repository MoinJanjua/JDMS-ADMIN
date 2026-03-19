//
//  AmeerJamatIntroViewController.swift
//  JDMS Admin
//
//  Created by Moin Janjua on 17/01/2026.
//

import UIKit
import SideMenu

class AmeerJamatIntroViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var messaegView: UITextView!
    
    // Add an indicator if you have one, or use a basic one
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLoader()
    }

    func setupUI() {
        messaegView.layer.cornerRadius = 8
        messaegView.layer.borderWidth = 1
        messaegView.layer.borderColor = UIColor.systemGray4.cgColor

        userImage.layer.cornerRadius = 10
        userImage.clipsToBounds = true
        userImage.contentMode = .scaleAspectFill
        userImage.backgroundColor = UIColor.systemGray5
    }
    
    private func setupLoader() {
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
    }

    // MARK: - Open Gallery Logic (Keep your existing code)
    @IBAction func AddImagebtnTapped(_ sender: UIButton) {
        let infoAlert = UIAlertController(
            title: "Banner Image Information",
            message: "Recommended size is 1536 × 672 for best appearance.",
            preferredStyle: .alert
        )
        infoAlert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { _ in self.openImagePicker() }))
        infoAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(infoAlert, animated: true)
    }

    func openImagePicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            userImage.image = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            userImage.image = originalImage
        }
        dismiss(animated: true)
    }
    
    @IBAction func backbtn(_ sender: UIButton) {
  
        self.dismiss(animated: true)

    }

    // MARK: - API Integration
    @IBAction func saveInfobtnTapped(_ sender: UIButton) {
        let message = messaegView.text ?? ""
        
        // 1. Validation
        guard !message.isEmpty else {
            showAlert(title: "Message Required", message: "Please enter a message.")
            return
        }
        
        guard let imageToUpload = userImage.image else {
            showAlert(title: "Image Required", message: "Please select an image first.")
            return
        }

        // 2. Start Loading
        activityIndicator.startAnimating()
        sender.isEnabled = false

        // STEP 1: Upload the Image first
        APIClient.shared.uploadTempImage(image: imageToUpload, messageType: "Banner") { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let uploadedUrl):
                
                let updatedParams = AmeerMessageData(
                        id: 1, // Your record ID
                        messageText: message,
                        imageUrl: uploadedUrl, // The relative path returned from upload-temp-image
                        isActive: true
                    )
                
                APIClient.shared.patchAmeerMessage(id: 1, params: updatedParams) { [weak self] result in
                        self?.activityIndicator.stopAnimating()
                        
                        switch result {
                        case .success:
                            self?.showToast(message: "Message Updated Successfully", font: .systemFont(ofSize: 15, weight: .semibold))
                            self?.dismiss(animated: true)
                            // Optionally navigate back or refresh
                        case .failure(let error):
                            self?.handleAPIError(error)
                        }
                    }

            case .failure(let error):
                self.activityIndicator.stopAnimating()
                sender.isEnabled = true
                self.showAlert(title: "Upload Failed", message: error.localizedDescription)
            }
        }
    }
    
}
