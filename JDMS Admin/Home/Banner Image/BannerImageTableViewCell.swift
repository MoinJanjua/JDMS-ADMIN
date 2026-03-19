//
//  BannerImageTableViewCell.swift
//  JDMS Admin
//
//  Created by Moin Janjua on 17/03/2026.
//

import UIKit

class BannerImageTableViewCell: UITableViewCell {

    @IBOutlet weak var bannerImage: UIImageView!
    @IBOutlet weak var delegtebtn: UIButton! // Your delete button
    
    // Closure to handle the delete action
    var onDeleteTapped: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    @IBAction func deletePressed(_ sender: UIButton) {
        onDeleteTapped?()
    }
}
