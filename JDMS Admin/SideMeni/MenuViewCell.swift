//
//  menuViewCell.swift
//  SourcePOS
//
//  Created by MacMini on 17/06/2021.
//

import UIKit

class MenuViewCell: UITableViewCell {
    @IBOutlet weak var ItemsLb: UILabel!
    @IBOutlet weak var ItemsImages: UIImageView!
    @IBOutlet weak var testView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
      
    }

    
}
