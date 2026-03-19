//
//  regionsTableViewCell.swift
//  JDMS Admin
//
//  Created by Moin Janjua on 04/01/2026.
//

import UIKit

class regionsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var districtlb: UILabel!
    @IBOutlet weak var bgView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        addDropShadow(to: bgView)
    }
}

