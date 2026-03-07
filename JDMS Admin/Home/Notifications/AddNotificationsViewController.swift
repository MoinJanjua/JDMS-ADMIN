//
//  AddNotificationsViewController.swift
//  JDMS Admin
//
//  Created by Moin Janjua on 12/01/2026.
//

import UIKit
import NVActivityIndicatorView

class AddNotificationsViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UITextField!
    @IBOutlet weak var messageLabel: UITextView! // Note: This is a TextView
    @IBOutlet weak var dateLabel: UITextField!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!
    
    private let datePicker = UIDatePicker()
    var existingNotification: NotificationRecord?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDatePicker()
        checkForEditMode()
    }
    
    private func checkForEditMode() {
        if let notify = existingNotification {
            titleLabel.text = notify.title
            messageLabel.text = notify.message
            
            // Parse existing date and update UI
            if let dateStr = notify.notifyDate {
                // Using your waterfall parser helper
                let dateObj = parseDateForSorting(dateStr) ?? Date()
                datePicker.date = dateObj
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd hh:mm a"
                dateLabel.text = formatter.string(from: dateObj)
            }
        }
    }
    
    private func setupUI() {
        addDropShadow(to: bgView)
        
        // Activity Indicator Setup
        activityIndicatorView.type = .ballRotate
        activityIndicatorView.color = primaryColor
        activityIndicatorView.isHidden = true
        
        // Urdu Font support
        titleLabel.font = .jameelNastaleeq(18)
        messageLabel.font = .jameelNastaleeq(16)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    private func setupDatePicker() {
        datePicker.datePickerMode = .dateAndTime
        if #available(iOS 14.0, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(hideKeyboard))
        toolbar.setItems([doneBtn], animated: true)
        
        dateLabel.inputView = datePicker
        dateLabel.inputAccessoryView = toolbar
        
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
    }
    
    @objc func dateChanged() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm a"
        dateLabel.text = formatter.string(from: datePicker.date)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    
    
    @IBAction func saveTapped(_ sender: UIButton) {
        // 1. Validation
        guard let title = titleLabel.text, !title.isEmpty,
              let message = messageLabel.text, !message.isEmpty,
              let dateText = dateLabel.text, !dateText.isEmpty else {
            showAlert(title: "Missing Info", message: "Please enter Title, Message, and Notification Date.")
            return
        }
        
        // 2. Format for API (ISO8601)
        let apiFormatter = ISO8601DateFormatter()
        apiFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let dateStr = apiFormatter.string(from: datePicker.date)
        
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
        
        if let notifyID = existingNotification?.id {
            // --- UPDATE MODE (PATCH) ---
            let updatedRecord = NotificationRecord(
                id: notifyID,
                title: title,
                message: message,
                notifyDate: dateStr,
                isActive: true, // Ensuring it stays active on update
                createdAt: existingNotification?.createdAt
            )
            
            APIClient.shared.updateNotification(id: notifyID, params: updatedRecord) { [weak self] result in
                self?.handleResult(result)
            }
            
        } else {
            // --- ADD MODE (POST) ---
            let request = NotificationPostRequest(
                title: title,
                message: message,
                notifyDate: dateStr
            )
            
            APIClient.shared.addNotification(params: request) { [weak self] result in
                self?.handleResult(result)
            }
        }
    }
    
    
    private func handleResult(_ result: Result<Bool, Error>) {
        DispatchQueue.main.async {
            self.activityIndicatorView.stopAnimating()
            self.activityIndicatorView.isHidden = true
            
            switch result {
            case .success:
                self.showSuccessAndDismiss()
            case .failure(let error):
                self.showAlert(title: "Error", message: error.localizedDescription)
            }
        }
    }
    
    private func showSuccessAndDismiss() {
        let title = existingNotification != nil ? "Updated" : "Success"
        let msg = existingNotification != nil ? "Notification updated successfully." : "Notification has been scheduled."
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.dismiss(animated: true)
        })
        present(alert, animated: true)
    }
    
    
    
    @IBAction func backbtnTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}
