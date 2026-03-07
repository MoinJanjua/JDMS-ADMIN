//
//  FormsTableViewCell.swift
//  JDMS Admin
//
//  Created by Moin Janjua on 12/01/2026.
//

import UIKit

class FormsTableViewCell: UITableViewCell {

    @IBOutlet weak var titlelb: UILabel!
    @IBOutlet weak var formtypelb: UILabel!
    @IBOutlet weak var questtypelb: UILabel!
    @IBOutlet weak var bgView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addDropShadow(to: bgView)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
