//
//  DetailMemberTableViewCell.swift
//  JDMS Admin
//
//  Created by Moin Janjua on 01/01/2026.
//

import UIKit

class DetailMemberTableViewCell: UITableViewCell {

    
    @IBOutlet weak var titleLb: UILabel!
    @IBOutlet weak var valueLb: UILabel!
    @IBOutlet weak var bgView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        addDropShadow(to: bgView)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
