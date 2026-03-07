//
//  DetailsFeedbackViewController.swift
//  JDMS Admin
//
//  Created by Moin Janjua on 15/01/2026.
//

import UIKit

class DetailsFeedbackViewController: UIViewController {

    @IBOutlet weak var messagelb: UILabel!
    @IBOutlet weak var datelb: UILabel!
    @IBOutlet weak var typelb: UILabel!
    @IBOutlet weak var submittedBylb: UILabel!
    @IBOutlet weak var typeView: UIView!
    
    var complaints: ComplaintRecord?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchUserName()
    }
    
    func setupUI() {
        messagelb.text = complaints?.details
        
        // Use the same date helper we used in the list for consistency
        datelb.text = formatDate(complaints?.createdAt)
        
        if complaints?.type == "1" {
            typeView.backgroundColor = .systemRed
            typelb.text = "Complaint"
        } else {
            typeView.backgroundColor = .systemGreen
            typelb.text = "Feedback"
        }
    }
    
    func fetchUserName() {
        guard let userId = complaints?.memberId, userId != 0 else {
            self.submittedBylb.text = "👤 Anonymous"
            return
        }
        
        // Initial loading state
        self.submittedBylb.text = "👤 Loading..."

        APIClient.shared.getUserProfile(id: userId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if let name = response.data?.name {
                        self?.submittedBylb.text = "👤 \(name)"
                    } else {
                        self?.submittedBylb.text = "👤 System User"
                    }
                case .failure:
                    self?.submittedBylb.text = "👤 Unknown User"
                }
            }
        }
    }

    @IBAction func backbtnTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
