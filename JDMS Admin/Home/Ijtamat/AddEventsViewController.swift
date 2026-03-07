//
//  AddEventsViewController.swift
//  JDMS Admin
//
//  Created by Moin Janjua on 19/01/2026.
//

import UIKit
import NVActivityIndicatorView

class AddEventsViewController: UIViewController {
    
    @IBOutlet weak var categorylb: UITextField!
    @IBOutlet weak var Startdatetf: UITextField!
    @IBOutlet weak var EnddateTf: UITextField!
    @IBOutlet weak var locationlb: UITextField!
    @IBOutlet weak var organizerlb: UITextField!
    @IBOutlet weak var speakerlb: UITextField!
    @IBOutlet weak var titlelb: UITextField!
    @IBOutlet weak var descriptionlb: UITextField!
    @IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!

    // Internal Pickers
    private let startDatePicker = UIDatePicker()
    private let endDatePicker = UIDatePicker()
    var existingEvent: EventRecord?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDatePickers()
        descriptionlb.font = .jameelNastaleeq(17)
        locationlb.font = .jameelNastaleeq(17)
        titlelb.font = .jameelNastaleeq(17)
        speakerlb.font = .jameelNastaleeq(17)
        categorylb.font = .jameelNastaleeq(17)
    }
    
    private func setupUI() {
        // Keyboard management
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        // Activity Indicator
        activityIndicatorView.type = .ballRotate
        activityIndicatorView.color = primaryColor
        activityIndicatorView.padding = 0
        activityIndicatorView.isHidden = true
        
        if let event = existingEvent {
            titlelb.text = event.title
            descriptionlb.text = event.description
            categorylb.text = event.category
            locationlb.text = event.location
            organizerlb.text = event.organizedBy
            speakerlb.text = event.speaker
            
            // 1. Convert strings to Date objects
            let sDate = parseDateForSorting(event.startDate) ?? Date()
            let eDate = parseDateForSorting(event.endDate) ?? Date()
            
            // 2. Assign to the actual Pickers
            startDatePicker.date = sDate
            endDatePicker.date = eDate
            
            // 3. Update the TextField TEXT so it's not empty
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "yyyy-MM-dd hh : mm a"
            
            Startdatetf.text = displayFormatter.string(from: sDate)
            EnddateTf.text = displayFormatter.string(from: eDate)
        }
    }
    private func setupDatePickers() {
        // Use the helper you likely have (attachDatePicker) or standard setup
        setupPicker(startDatePicker, for: Startdatetf)
        setupPicker(endDatePicker, for: EnddateTf)
    }

    private func setupPicker(_ picker: UIDatePicker, for textField: UITextField) {
        picker.datePickerMode = .dateAndTime
        if #available(iOS 14.0, *) {
            picker.preferredDatePickerStyle = .wheels
        }
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(hideKeyboard))
        toolbar.setItems([doneBtn], animated: true)
        
        textField.inputView = picker
        textField.inputAccessoryView = toolbar
        
        // Update text field when date changes
        picker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
    }

    @objc func dateChanged(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh : mm a"
        if sender == startDatePicker {
            Startdatetf.text = formatter.string(from: sender.date)
        } else {
            EnddateTf.text = formatter.string(from: sender.date)
        }
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    
    @IBAction func saveTapped(_ sender: UIButton) {
        // 1. Strict Mandatory Validation
        guard let title = titlelb.text, !title.isEmpty,
              let desc = descriptionlb.text, !desc.isEmpty,
              let category = categorylb.text, !category.isEmpty,
              let location = locationlb.text, !location.isEmpty,
              let startText = Startdatetf.text, !startText.isEmpty,
              let endText = EnddateTf.text, !endText.isEmpty else {
            showAlert(title: "Validation", message: "Please fill all mandatory fields: Title, Description, Dates, Category, and Location.")
            return
        }

        // 2. Logic Validation
        if endDatePicker.date <= startDatePicker.date {
            showAlert(title: "Validation", message: "End date must be after the start date.")
            return
        }

        // 3. Format Dates for API
        let apiFormatter = ISO8601DateFormatter()
        apiFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let startStr = apiFormatter.string(from: startDatePicker.date)
        let endStr = apiFormatter.string(from: endDatePicker.date)
        
        // 4. API Handling
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()

        if let eventID = existingEvent?.id {
            // --- UPDATE MODE (PATCH) ---
            let updatedEvent = EventRecord(
                id: eventID,
                title: title,
                description: desc,
                category: category,
                organizedBy: organizerlb.text ?? "",
                location: location,
                startDate: startStr,
                endDate: endStr,
                speaker: speakerlb.text ?? "",
                isActive: true, // Keep it active during update
                createdAt: existingEvent?.createdAt // Preserve original creation date
            )
            
            APIClient.shared.updateEvent(id: eventID, params: updatedEvent) { [weak self] result in
                self?.handleAPIResponse(result)
            }
            
        } else {
            // --- ADD MODE (POST) ---
            let newEvent = EventPostRequest(
                title: title,
                startDate: startStr,
                endDate: endStr,
                description: desc,
                category: category,
                organizedBy: organizerlb.text ?? "",
                location: location,
                speaker: speakerlb.text ?? ""
            )
            
            APIClient.shared.addEvent(params: newEvent) { [weak self] result in
                self?.handleAPIResponse(result)
            }
        }
    }

    // Helper to keep the code clean and handle responses in one place
    private func handleAPIResponse(_ result: Result<Bool, Error>) {
        DispatchQueue.main.async {
            self.activityIndicatorView.stopAnimating()
            self.activityIndicatorView.isHidden = true
            
            switch result {
            case .success:
                self.showSuccessAndDismiss()
            case .failure(let error):
                let nsError = error as NSError
                if nsError.code == 401 {
                    self.showAlertWithButtons(title: "Session Expired", message: "Please login again.", okTitle: "Login", cancelTitle: nil) {
                        AppNavigator.navigateToLogin()
                    }
                } else {
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }

    private func showSuccessAndDismiss() {
        let alert = UIAlertController(title: "Success", message: "Event added successfully!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.dismiss(animated: true)
        })
        present(alert, animated: true)
    }

    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Validation", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @IBAction func backbtnTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}
