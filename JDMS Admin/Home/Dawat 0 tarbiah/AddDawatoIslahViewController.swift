//
//  AddDawatoIslahViewController.swift
//  JDMS Admin
//
//  Created by Moin Janjua on 03/01/2026.
//

import UIKit
import UniformTypeIdentifiers
import NVActivityIndicatorView

//
class AddDawatoIslahViewController: UIViewController {

    @IBOutlet weak var titlelb: UITextField!
    @IBOutlet weak var shortdesclb: UITextField!
    @IBOutlet weak var categorylb: UITextField!
    @IBOutlet weak var longDescTV: UITextView!
    @IBOutlet weak var longDescHeight: NSLayoutConstraint!
    @IBOutlet weak var datelb: UITextField!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var pdfbtn: UIButton!
    @IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!

    private let datePicker = UIDatePicker()
    private var selectedPDFPath: String?
    private var selectedPDFURL: URL? // Use URL instead of Path for better security
    var editItem: DawatRecord?
    var isEditingMode = false
    private var isNewPDFSelected = false

    override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
            
            if isEditingMode {
                setupEditMode()
            } else {
                //loadSavedData() // Load drafts for new entries
            }
        }
    
    private func setupUI()
    {
        activityIndicatorView.isHidden = true
        roundCornertextView(textView: longDescTV, cornerRadius: 10)
        setupActivityIndicator()
        addDropShadow(to: bgView)
        
        longDescTV.font = .jameelNastaleeq(17)
        titlelb.font = .jameelNastaleeq(17)
        shortdesclb.font = .jameelNastaleeq(17)
        categorylb.font = .jameelNastaleeq(17)
        pdfbtn.setTitle("Upload File 📎", for: .normal)
        attachDatePicker(to: datelb, mode: .date, format: "dd-MM-yyyy")
    }
    
    
    private func setupEditMode()
    {
        guard let item = editItem else { return }
        titlelb.text = item.title
        shortdesclb.text = item.shortDescription
        categorylb.text = item.category
        
        if let content = item.content, !content.isEmpty {
            longDescTV.text = content
            longDescHeight.constant = 200
        } else if let pdf = item.pdfUrl, !pdf.isEmpty {
            pdfbtn.setTitle("Existing PDF Attached ✅", for: .normal)
            longDescHeight.constant = 0
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        stopAnimating()
    }
    
    
    func setupActivityIndicator()
    {
        activityIndicatorView.type = .ballRotate
        activityIndicatorView.color = primaryColor
        activityIndicatorView.padding = 0
    }
    // MARK: - Date Picker

 

    // MARK: - Load Saved Data
//    private func loadSavedData() {
//        let defaults = UserDefaults.standard
//
//        titlelb.text = defaults.string(forKey: "title")
//        shortdesclb.text = defaults.string(forKey: "shortDesc")
//        categorylb.text = defaults.string(forKey: "category")
//        longDescTV.text = defaults.string(forKey: "longDesc")
//        datelb.text = defaults.string(forKey: "date")
//        selectedPDFPath = defaults.string(forKey: "pdfPath")
//    }

    // MARK: - Actions
    @IBAction func backbtnTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }

    // Upload PDF
    @IBAction func uploadbtnbtnTapped(_ sender: UIButton) {
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
        longDescHeight.constant = 0
        pickPDF()
    }

    // Enter Long Description
    @IBAction func longDescbtnTapped(_ sender: UIButton) {
        pdfbtn.setTitle("Upload File 📎", for: .normal)
        longDescHeight.constant = 200
        selectedPDFURL = nil
        isNewPDFSelected = false
    }


    
    @IBAction func SavebtnTapped(_ sender: UIButton) {
        guard let title = titlelb.text, !title.isEmpty,
              let shortDesc = shortdesclb.text, !shortDesc.isEmpty,
              let category = categorylb.text, !category.isEmpty else {
            showAlert("Title, Short Description, and Category are required.")
            return
        }

        let contentText = longDescTV.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        // Logic check:
        let hasNewPDFLocal = selectedPDFURL != nil // User just picked one
        let hasRemotePDF = isEditingMode && !(editItem?.pdfUrl?.isEmpty ?? true) // Already exists on server
        let hasText = !contentText.isEmpty // User typed text

        // If all are empty, THEN show alert
        if !hasNewPDFLocal && !hasRemotePDF && !hasText {
            showAlert("Please either upload a PDF or enter a Long Description.")
            return
        }

        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()

        if isNewPDFSelected, let fileURL = selectedPDFURL {
            // FLOW: Uploading a brand new PDF (Works for New or Edit mode)
            uploadAndSave(fileURL: fileURL, title: title, shortDesc: shortDesc, category: category)
        } else {
            // FLOW: Using existing text or the old PDF path
            let existingPath = isEditingMode ? editItem?.pdfUrl : nil
            finalSaveDawat(title: title, shortDesc: shortDesc, category: category, content: contentText, pdfPath: existingPath)
        }
    }
    
    
    private func uploadAndSave(fileURL: URL, title: String, shortDesc: String, category: String) {
            APIClient.shared.uploadDawatPDF(fileURL: fileURL) { [weak self] result in
                switch result {
                case .success(let remotePath):
                    self?.finalSaveDawat(title: title, shortDesc: shortDesc, category: category, content: "", pdfPath: remotePath)
                case .failure(let error):
                    self?.stopAnimating()
                    self?.handleAPIError(error)
                }
            }
        }
    
    
    private func finalSaveDawat(title: String, shortDesc: String, category: String, content: String, pdfPath: String?) {
        
        // This closure handles the UI response after the API call finishes
        let completion: (Result<Bool, Error>) -> Void = { [weak self] result in
            self?.stopAnimating()
            switch result {
            case .success:
                let msg = self?.isEditingMode ?? false ? "Updated successfully!" : "Saved successfully!"
                self?.showSuccessAlert(message: msg)
            case .failure(let error):
                self?.handleAPIError(error)
            }
        }

        if isEditingMode {
            // Use the model that includes 'id' for the PUT request
            let updateBody = DawatRecord(
                id: editItem?.id ?? 0,
                title: title,
                shortDescription: shortDesc,
                content: content,
                category: category,
                pdfUrl: pdfPath ?? "",
                isActive: true
            )
            APIClient.shared.updateDawat(item: updateBody, completion: completion)
            
        } else {
            // Use the model WITHOUT 'id' for the POST request
            let postBody = DawatPostRequest(
                title: title,
                shortDescription: shortDesc,
                content: content,
                category: category,
                pdfUrl: pdfPath ?? ""
            )
            APIClient.shared.addDawat(params: postBody, completion: completion)
        }
    }

    private func showSuccessAlert(message: String) {
        let alert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.dismiss(animated: true)
        })
        self.present(alert, animated: true)
    }
    
    
    func stopAnimating()
    {
        activityIndicatorView.isHidden = true
        activityIndicatorView.stopAnimating()
    }
}

// MARK: - PDF Picker
extension AddDawatoIslahViewController: UIDocumentPickerDelegate {

    private func pickPDF() {
            let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf], asCopy: true)
            picker.delegate = self
            present(picker, animated: true)
        }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        stopAnimating()
        guard let url = urls.first else { return }

        // 1. Store the path
        self.selectedPDFURL = url
        self.isNewPDFSelected = true
        
        // 2. Clear text and hide text view (Professional touch)
        longDescTV.text = ""
        UIView.animate(withDuration: 0.3) {
            self.longDescHeight.constant = 0
            self.view.layoutIfNeeded()
        }
        
        // 3. Show a success message or change button color
       // print("PDF Selected: \(url.lastPathComponent)")
        pdfbtn.setTitle("New PDF Selected 📎", for: .normal)
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        stopAnimating()
    }
}

// MARK: - Alert Helper
extension AddDawatoIslahViewController {
    private func showAlert(_ message: String) {
        let alert = UIAlertController(
            title: "Validation Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
