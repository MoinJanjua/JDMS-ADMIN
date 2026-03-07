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
    @IBOutlet weak var districtLb: UILabel!
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
        roundCorneView(view: verifyView)
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func verifyBtnPressed(_ sender: UIButton) {
            onVerifyTap?()
        }

}
