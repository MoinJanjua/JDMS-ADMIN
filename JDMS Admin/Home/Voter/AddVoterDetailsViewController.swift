//
//  VoterDetailsViewController.swift
//  JDMS Admin
//
//  Created by Moin Janjua on 18/01/2026.
//

import UIKit
import SideMenu
import NVActivityIndicatorView

class AddVoterDetailsViewController: UIViewController {

    
    @IBOutlet weak var memeberDD: DropDown!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var namelb: UITextField!
    @IBOutlet weak var Fathernamelb: UITextField!
    @IBOutlet weak var Cniclb: UITextField!
    @IBOutlet weak var voterIdlb: UITextField!
    @IBOutlet weak var pollingStationlb: UITextField!
    @IBOutlet weak var blockCodelb: UITextField!
    @IBOutlet weak var halqaLblb: UITextField!
    @IBOutlet weak var Adddatelb: UITextField!
    @IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!
    
    
    var searchedMembers: [Member] = []
        var selectedMemberId: Int?
    var searchTimer: Timer?
    let datePicker = UIDatePicker()
    
    var existingRecord: MemberVoteRecord? // Data passed from Details
    var isEditingMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDatePicker()
        addDropShadow(to: bgView)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        prefillData()
        setupSearchableDropDown()
    }
    
    
    func prefillData() {
        guard let record = existingRecord else { return }
        
        // 1. Fill Voter Info fields
        voterIdlb.text = record.voterId
        pollingStationlb.text = record.pollingStation
        blockCodelb.text = record.blockCode
        halqaLblb.text = record.halqaNumber
        
        // 2. Fill Nested Member Info fields
        if let member = record.member {
            namelb.text = member.fullName
            Fathernamelb.text = member.fatherName
            Cniclb.text = member.cnic
            
            // If your DropDown needs the selected item name:
            memeberDD.text = member.fullName
        }
        
        // 3. Handle the Date string
        if let dateString = record.voteRegistrationDate {
            // We take the first 10 characters (YYYY-MM-DD) for a cleaner look
            Adddatelb.text = String(dateString.prefix(10))
        }
        
        // Optional: Disable member fields if you don't want users
        // to edit Member info from the Voting Info screen
         namelb.isEnabled = false
         Cniclb.isEnabled = false
    }
    
    private func setupDatePicker() {
            // Configure DatePicker Style
            datePicker.datePickerMode = .date
            if #available(iOS 13.4, *) {
                datePicker.preferredDatePickerStyle = .wheels
            }
            
            // Create a Toolbar with a Done button
            let toolbar = UIToolbar()
            toolbar.sizeToFit()
            let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))
            let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            toolbar.setItems([flexibleSpace, doneBtn], animated: true)
            
            // Assign picker and toolbar to the text field
            Adddatelb.inputView = datePicker
            Adddatelb.inputAccessoryView = toolbar
        }
    
    @objc func donePressed() {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            Adddatelb.text = formatter.string(from: datePicker.date)
            view.endEditing(true)
        }
    
    
    private func setupSearchableDropDown() {
            // This triggers when the user types in the DropDown search bar
           
            // Listen for typing to call the API
            memeberDD.addTarget(self, action: #selector(searchFieldDidChange(_:)), for: .editingChanged)

            // Handle Selection
            memeberDD.didSelect { [weak self] (selectedText, index, id) in
                guard let self = self, index < self.searchedMembers.count else { return }
                
                let member = self.searchedMembers[index]
                self.selectedMemberId = member.id
                
                // Auto-fill fields from database record
                self.namelb.text = member.fullName
                self.Fathernamelb.text = member.fatherName
                self.Cniclb.text = member.cnic
                self.memeberDD.hideList()
                // Disable editing for these fields to maintain data integrity
                [self.namelb, self.Fathernamelb, self.Cniclb].forEach { $0?.isEnabled = false }
            }
        }

    @objc func searchFieldDidChange(_ textField: UITextField) {
        // Cancel the previous timer
        searchTimer?.invalidate()
        
        guard let searchText = textField.text, searchText.count >= 3 else {
            self.memeberDD.hideList()
            return
        }

        // Wait 0.5 seconds after the user stops typing before calling the API
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            self?.performDatabaseSearch(query: searchText)
        }
    }
    
    private func performDatabaseSearch(query: String) {
        startLoading(view: activityIndicatorView)
        
        APIClient.shared.searchMembers(query: query) { [weak self] result in
            self?.activityIndicatorView.stopAnimating()
            
            switch result {
            case .success(let members):
                self?.searchedMembers = members
                // Map the results to the dropdown
                self?.memeberDD.optionArray = members.map { "\($0.fullName) (\($0.cnic))" }
                self?.memeberDD.showList()
                
            case .failure(let error):
                self?.handleAPIError(error)
            }
        }
    }
    
    @objc func hideKeyboard()
      {
          view.endEditing(true)
      }
    
    

    @IBAction func saveVoterInfoTapped(_ sender: UIButton) {
            // 1. Validation
           
            
            guard let voterId = voterIdlb.text, !voterId.isEmpty,
                  let pollingStation = pollingStationlb.text, !pollingStation.isEmpty,
                  let blockCode = blockCodelb.text, !blockCode.isEmpty,
                  let halqa = halqaLblb.text, !halqa.isEmpty,
                  let regDate = Adddatelb.text, !regDate.isEmpty else {
                showAlert(title: "Missing Information", message: "Please fill in all voter details fields.")
                return
            }
        
        if isEditingMode {
            
            guard let recordId = existingRecord?.id else { return }
            
            let updateData = MemberVoteUpdateRequest(
                    id: recordId,
                    voterId: voterIdlb.text ?? "",
                    pollingStation: pollingStationlb.text ?? "",
                    blockCode: blockCodelb.text ?? "",
                    halqaNumber: halqaLblb.text ?? "",
                    voteRegistrationDate: Adddatelb.text ?? ""
                )
            self.activityIndicatorView.startAnimating()
            
            APIClient.shared.updateVoterRecord(record: updateData) { [weak self] result in
                DispatchQueue.main.async {
                    self?.activityIndicatorView.stopAnimating()
                    
                    switch result {
                    case .success:
                        let alert = UIAlertController(title: "Success", message: "Record updated successfully", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                            // This dismisses the current screen (Edit) AND the one below it (Details)
                            self?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                        }))
                        self?.present(alert, animated: true)
                    case .failure(let error):
                        self?.handleAPIError(error)
                    }
                }
            }
        }
        else
        {
            
            guard let memberId = selectedMemberId else {
                showAlert(title: "Selection Required", message: "Please search and select a member first.")
                return
            }
            
            // 2. Prepare Request
            let isoDate = formatToISO8601(dateString: regDate)
            let params = AddVoterRequest(
                voterId: voterId,
                pollingStation: pollingStation,
                blockCode: blockCode,
                halqaNumber: halqa,
                voteRegistrationDate: isoDate,
                memberId: memberId
            )
            
            // 3. Call API
            startLoading(view: activityIndicatorView)
            APIClient.shared.addMemberVotingInfo(params: params) { [weak self] result in
                self?.activityIndicatorView.stopAnimating()
                
                switch result {
                case .success(let message):
                    self?.showAlertWithButtons(title: "Success", message: message) {
                        self?.dismiss(animated: true) // Go back after success
                    }
                case .failure(let error):
                    self?.handleAPIError(error)
                }
            }
        }
        }

        // Helper to format date for API
        func formatToISO8601(dateString: String) -> String {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "yyyy-MM-dd"
            if let date = displayFormatter.date(from: dateString) {
                let isoFormatter = ISO8601DateFormatter()
                isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                return isoFormatter.string(from: date)
            }
            return ""
        }

    @IBAction func backbtnTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }

}
