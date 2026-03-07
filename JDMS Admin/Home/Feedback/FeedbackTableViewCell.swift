//
//  FeedbackTableViewCell.swift
//  JDMS Admin
//
//  Created by Moin Janjua on 15/01/2026.
//

import UIKit

class FeedbackTableViewCell: UITableViewCell {

    @IBOutlet weak var complaintype: UILabel!
    @IBOutlet weak var messagelb: UILabel!
    @IBOutlet weak var suggestionimage: UIImageView!
    @IBOutlet weak var submittedBylb: UILabel!
    @IBOutlet weak var comaplinView: UIView!
    @IBOutlet weak var bgview: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addDropShadow(to: bgview)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
