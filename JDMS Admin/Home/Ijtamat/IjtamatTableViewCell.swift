//
//  IjtamatTableViewCell.swift
//  JDMS Admin
//
//  Created by Moin Janjua on 11/01/2026.
//

import UIKit

class IjtamatTableViewCell: UITableViewCell {

    @IBOutlet weak var titlelb: UILabel!
    @IBOutlet weak var descriptionlblb: UILabel!
    @IBOutlet weak var statuslb: UILabel!
    @IBOutlet weak var datelb: UILabel!
    @IBOutlet weak var imageBg: UIView!
    @IBOutlet weak var statusBG: UIView!
    @IBOutlet weak var bgview: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        roundCorneView(view: imageBg)
       // roundCorneView(view: statusBG)
        titlelb.font = .jameelNastaleeqBold(17, isBold: true)
        descriptionlblb.font = .jameelNastaleeq(16)
        addDropShadow(to: bgview)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
