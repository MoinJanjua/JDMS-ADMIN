//
//  UserTableViewCell.swift
//  JDMS Admin
//
//  Created by Moin Janjua on 14/03/2026.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    
    @IBOutlet weak var usernamelb: UILabel!
    @IBOutlet weak var lstmessagelb: UILabel!
    @IBOutlet weak var messagetime: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var messageCountView: UIView!
    @IBOutlet weak var messageCountlb: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        addDropShadow(to: bgView)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}


class AddUserTableViewCell: UITableViewCell {
    
    @IBOutlet weak var usernamelb: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var bgView: UIView!
    
    var onAddTap: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        addDropShadow(to: bgView)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
            onAddTap?()
        }

}
