//
//  DesiginationTableViewCell.swift
//  JDMS Admin
//
//  Created by Moin Janjua on 11/01/2026.
//

import UIKit

class DesiginationTableViewCell: UITableViewCell {

    @IBOutlet weak var titlelb: UILabel!
    @IBOutlet weak var BgView: UIView!
    @IBOutlet weak var deletebtn: UIButton!
    @IBOutlet weak var editbtn: UIButton!
  
    var onDeleteTap: (() -> Void)? // Callback closure
    var onEditTap: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        addDropShadow(to: BgView)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func deletePressed(_ sender: UIButton) {
            onDeleteTap?()
        }
    
    
    @IBAction func editPressed(_ sender: UIButton)
    {
            onEditTap?()
    }

}
