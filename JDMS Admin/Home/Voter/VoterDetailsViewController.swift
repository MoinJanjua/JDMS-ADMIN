//
//  VoterDetailsViewController.swift
//  JDMS Admin
//
//  Created by Moin Janjua on 18/01/2026.
//

import UIKit


class VoterDetailsViewController: UIViewController {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var namelb: UILabel!
    @IBOutlet weak var Fathernamelb: UILabel!
    @IBOutlet weak var Cniclb: UILabel!
    @IBOutlet weak var voterIdlb: UILabel!
    @IBOutlet weak var pollingStationlb: UILabel!
    @IBOutlet weak var blockCodelb: UILabel!
    @IBOutlet weak var halqaLblb: UILabel!
    @IBOutlet weak var Adddatelb: UILabel!
    
    // Using the dynamic model we created
    var voterList: MemberVoteRecord?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        namelb.text = voterList?.member?.fullName
        Fathernamelb.text = voterList?.member?.fatherName
        Cniclb.text = "CNIC: \(voterList?.member?.cnic ?? "")"
        voterIdlb.text = voterList?.voterId
        pollingStationlb.text = voterList?.pollingStation
        blockCodelb.text = "Block Code: \(voterList?.blockCode ?? "")"
        halqaLblb.text = "LA: \(voterList?.halqaNumber ?? "")"
        
        // Formatting the date for better readability
        if let dateStr = voterList?.voteRegistrationDate {
            Adddatelb.text = "Updated: \(dateStr.prefix(10))"
        }
    }
    
    @IBAction func backbtnTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }

    // MARK: - Edit Action
    @IBAction func editbtnTapped(_ sender: UIButton) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let editVC = storyBoard.instantiateViewController(withIdentifier: "AddVoterDetailsViewController") as? AddVoterDetailsViewController {
            
            // Pass the existing record to the Add/Edit screen
            editVC.existingRecord = self.voterList
            editVC.isEditingMode = true
            
            editVC.modalPresentationStyle = .fullScreen
            editVC.modalTransitionStyle = .crossDissolve
            self.present(editVC, animated: true)
        }
    }
    
    // MARK: - Delete Action
    @IBAction func deletebtnTapped(_ sender: UIButton) {
        guard let recordId = voterList?.id else { return }
        
        let alert = UIAlertController(title: "Confirm Delete",
                                      message: "Are you sure you want to permanently delete this voting record?",
                                      preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.performDelete(id: recordId)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // For iPad support
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        self.present(alert, animated: true)
    }
    
    
    
    @IBAction func printbtnTapped(_ sender: UIButton) {
        guard let voter = voterList else { return }
        
        // 1. Convert local "banner" image to Base64
        var base64ImageString = ""
        if let bannerImage = UIImage(named: "banner"),
           let imageData = bannerImage.jpegData(compressionQuality: 0.8) {
            base64ImageString = imageData.base64EncodedString()
        }

        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.outputType = .general
        printInfo.jobName = "Voter Details - \(voter.member?.fullName ?? "Record")"
        
        let printController = UIPrintInteractionController.shared
        printController.printInfo = printInfo
        
        // 2. Insert image into HTML using <img> tag with base64 data
        let htmlContent = """
        <html>
        <head>
            <style>
                body { font-family: 'Helvetica', sans-serif; padding: 20px; color: #333; }
                .banner-img { width: 100%; height: auto; max-height: 200px; object-fit: cover; border-radius: 8px; margin-bottom: 20px; }
                .header { text-align: center; color: #1B5E20; margin-bottom: 10px; }
                .info-table { width: 100%; border-collapse: collapse; margin-top: 10px; }
                .info-table td { padding: 12px; border-bottom: 1px solid #eee; }
                .label { font-weight: bold; color: #555; width: 35%; }
                .footer { margin-top: 40px; text-align: center; font-size: 10px; color: #888; border-top: 1px solid #eee; padding-top: 10px; }
            </style>
        </head>
        <body>
            <img src="data:image/jpeg;base64,\(base64ImageString)" class="banner-img">
            
            <h2 class="header">Voter Registration Record</h2>
            
            <table class="info-table">
                <tr><td class="label">Full Name</td><td>\(voter.member?.fullName ?? "N/A")</td></tr>
                <tr><td class="label">Father Name</td><td>\(voter.member?.fatherName ?? "N/A")</td></tr>
                <tr><td class="label">CNIC</td><td>\(voter.member?.cnic ?? "N/A")</td></tr>
                <tr><td class="label">Voter ID</td><td>\(voter.voterId ?? "N/A")</td></tr>
                <tr><td class="label">Polling Station</td><td>\(voter.pollingStation ?? "N/A")</td></tr>
                <tr><td class="label">Block Code</td><td>\(voter.blockCode ?? "N/A")</td></tr>
                <tr><td class="label">Halqa/LA Number</td><td>\(voter.halqaNumber ?? "N/A")</td></tr>
            </table>

            <div class="footer">
                Generated by Jamaat Digital Management System<br>
                Date: \(Date().formatted(date: .abbreviated, time: .shortened))
            </div>
        </body>
        </html>
        """
        
        let formatter = UIMarkupTextPrintFormatter(markupText: htmlContent)
        // Add some margins to the page
        formatter.perPageContentInsets = UIEdgeInsets(top: 36, left: 36, bottom: 36, right: 36)
        
        printController.printFormatter = formatter
        printController.present(animated: true, completionHandler: nil)
    }
    @IBAction func sharebtnTapped(_ sender: UIButton) {
            guard let voter = voterList else { return }
            
            // Construct a clean, professional message
            let shareMessage = """
            🗳️ *VOTER INFORMATION DETAILS*
            ----------------------------
            👤 Name: \(voter.member?.fullName ?? "N/A")
            👨‍👩‍👦 Father Name: \(voter.member?.fatherName ?? "N/A")
            🆔 CNIC: \(voter.member?.cnic ?? "N/A")
            🎫 Voter ID: \(voter.voterId ?? "N/A")
            ----------------------------
            📍 Polling Station: \(voter.pollingStation ?? "N/A")
            🏗️ Block Code: \(voter.blockCode ?? "N/A")
            🏛️ Halqa/LA: \(voter.halqaNumber ?? "N/A")
            ----------------------------
            📱 Shared via Jamaat Digital Management System
            """
            
            let activityVC = UIActivityViewController(activityItems: [shareMessage], applicationActivities: nil)
            
            // For iPad support
            if let popoverController = activityVC.popoverPresentationController {
                popoverController.sourceView = sender
                popoverController.sourceRect = sender.bounds
            }
            
            self.present(activityVC, animated: true)
        }
    
    private func performDelete(id: Int) {
        // Show loading if you have a global indicator or activityIndicatorView
        APIClient.shared.deleteVoterRecord(id: id) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    // Success! Go back to the list
                    self?.dismiss(animated: true)
                case .failure(let error):
                    self?.handleAPIError(error)
                }
            }
        }
    }
}
