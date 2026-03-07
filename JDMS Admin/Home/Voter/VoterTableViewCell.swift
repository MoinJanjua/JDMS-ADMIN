//
//  VoterTableViewCell.swift
//  JDMS Admin
//
//  Created by Moin Janjua on 18/01/2026.
//

import UIKit

class VoterTableViewCell: UITableViewCell {

    @IBOutlet weak var namelb: UILabel!
    @IBOutlet weak var Fathernamelb: UILabel!
    @IBOutlet weak var cniclb: UILabel!
    @IBOutlet weak var voterIDlb: UILabel!
    @IBOutlet weak var pollingStationlb: UILabel!
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
