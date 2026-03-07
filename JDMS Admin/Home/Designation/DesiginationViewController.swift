//
//  DesiginationViewController.swift
//  JDMS Admin
//
//  Created by Moin Janjua on 29/12/2025.
//

import UIKit
import SideMenu
import NVActivityIndicatorView

class DesiginationViewController: UIViewController {

    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var designationTF: UITextField!
    @IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!
    @IBOutlet weak var saveButton: UIButton!
    
    var designations: [Designation] = []
    var editingDesignation: Designation?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tv.delegate = self
        tv.dataSource = self
        tv.separatorStyle = .none
       
        activityIndicatorView.type = .ballPulseSync
        activityIndicatorView.color = .systemGreen
        activityIndicatorView.isHidden = true // Keep it hidden until needed
        
        loadDesignations()
    }
    
    func loadDesignations() {
        
        DispatchQueue.main.async {
            self.activityIndicatorView.startAnimating()
        }
        APIClient.shared.getDesignations { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicatorView.stopAnimating()
                switch result {
                case .success(let list):
                    self?.designations = list
                    self?.tv.reloadData()
                    
                case .failure(let error):
                    self?.handleAPIError(error)
                    self?.tv.reloadData()
                }
            }
        }
    }
    

 
    @IBAction func openMenu(_ sender: UIButton) {
        let Menu = storyboard?.instantiateViewController(withIdentifier:"SideMenuNavigation") as? SideMenuNavigationController
        Menu?.leftSide = true
        Menu?.settings = makeSettings()
        SideMenuManager.default.leftMenuNavigationController = Menu
        present(Menu!, animated: true, completion: nil)

    }
    
    
    @IBAction func saveDesignationTapped(_ sender: UIButton) {
        guard let title = designationTF.text, !title.isEmpty else {
            self.showAlert(title: "Error!", message: "Please enter a valid Title")
            return
        }

        if let existing = editingDesignation {
            // --- UPDATE MODE ---
            let updatedData = Designation(
                id: existing.id,
                title: title,
                urduTitle: existing.urduTitle, level: existing.level,
                responsibilities: existing.responsibilities
            )
            
            self.activityIndicatorView.startAnimating()
            APIClient.shared.updateDesignation(id: existing.id, params: updatedData) { [weak self] result in
                self?.activityIndicatorView.stopAnimating()
                switch result {
                case .success:
                    self?.saveButton.setTitle("Update Record", for: .normal)
                    self?.showToast(message: "Updated Successfully", font: .systemFont(ofSize: 15, weight: .semibold))
                    self?.editingDesignation = nil // Reset state
                    self?.designationTF.text = ""
                    self?.loadDesignations()
                case .failure(let error):
                    self?.handleAPIError(error)
                }
            }
        } else {
            // --- ADD MODE (Your existing logic) ---
            let requestBody = DesignationPostRequest(title: title, level: 1, urduTitle: "", responsibilities: "")
            self.activityIndicatorView.startAnimating()
            APIClient.shared.addDesignation(params: requestBody) { [weak self] result in
                self?.activityIndicatorView.stopAnimating()
                switch result {
                case .success:
                    self?.showToast(message: "Added Successfully", font: .systemFont(ofSize: 15, weight: .semibold))
                    self?.designationTF.text = ""
                    self?.loadDesignations()
                case .failure(let error):
                    self?.handleAPIError(error)
                }
            }
        }
    }
    
    
    private func confirmDelete(designation: Designation) {
        self.showAlertWithButtons(
            title: "Confirm Delete",
            message: "Are you sure you want to delete '\(designation.title)'?",
            okTitle: "Delete",
            cancelTitle: "Cancel"
        ) {
            self.performDelete(id: designation.id)
        }
    }
    
    
    private func performDelete(id: Int) {
        self.activityIndicatorView.startAnimating()
        APIClient.shared.deleteDesignation(id: id) { [weak self] result in
            self?.activityIndicatorView.stopAnimating()
            
            switch result {
            case .success:
                self?.showToast(message: "Designation Deleted", font: .systemFont(ofSize: 15, weight: .semibold))
                self?.loadDesignations() // Refresh the list
            case .failure(let error):
                self?.handleAPIError(error)
            }
        }
    }

}


extension DesiginationViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return designations.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "cell",
            for: indexPath
        ) as! DesiginationTableViewCell

        let desigination = designations[indexPath.row]

        cell.titlelb.text = desigination.title
       
        cell.onDeleteTap = { [weak self] in
            self?.confirmDelete(designation: desigination)
            }
        
        cell.onEditTap = { [weak self] in
            self?.saveButton.setTitle("Update Record", for: .normal)
            self?.editingDesignation = desigination
            self?.designationTF.text = desigination.title
            self?.designationTF.becomeFirstResponder() // Open keyboard
        }
        
        
        return cell
    }
    
  }

