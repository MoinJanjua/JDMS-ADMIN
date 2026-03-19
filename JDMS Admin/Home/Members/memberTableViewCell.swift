//
//  memberTableViewCell.swift
//  JDMS Admin
//
//  Created by Moin Janjua on 01/01/2026.
//

import UIKit

class memberTableViewCell: UITableViewCell {

    @IBOutlet weak var NameLb: UILabel!
    @IBOutlet weak var FNameLb: UILabel!
    @IBOutlet weak var cityLb: UILabel!
    @IBOutlet weak var EducationLb: UILabel!
    @IBOutlet weak var bgview: UIView!
    @IBOutlet weak var verifyView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var veirfybutton: UIButton!
    
    var onVerifyTap: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        addDropShadow(to: bgview)
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.clipsToBounds = true
        
        let canVerify = PermissionManager.shared.canPerform(action: .verifyMember)
            veirfybutton.isEnabled = canVerify
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // 1. Cancel the current download if it's still running
        profileImageView.sd_cancelCurrentImageLoad()
        
        // 2. Reset the image to nil so the old person's face doesn't show
        profileImageView.image = nil
    }
    
    @IBAction func verifyBtnPressed(_ sender: UIButton) {
        if PermissionManager.shared.canPerform(action: .verifyMember) {
            onVerifyTap?()
        } else {
            print("Unauthorized attempt to verify member.")
            // You could even trigger a small shake animation or a toast here
        }
    }

}
