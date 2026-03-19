//
//  SystemTableViewCell.swift
//  JDMS Admin
//
//  Created by Moin Janjua on 13/03/2026.
//

import UIKit

class SystemTableViewCell: UITableViewCell {

    @IBOutlet weak var NameLb: UILabel!
    @IBOutlet weak var emailLb: UILabel!
    @IBOutlet weak var phoneLb: UILabel!
    @IBOutlet weak var roleLb: UILabel!
    @IBOutlet weak var registeredLb: UILabel!
    @IBOutlet weak var bgview: UIView!
    @IBOutlet weak var assignrole: UIButton!
    
    var onAssignRoleTap: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addDropShadow(to: bgview)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func assignRoleTapped(_ sender: UIButton) {
            onAssignRoleTap?()
        }

}
