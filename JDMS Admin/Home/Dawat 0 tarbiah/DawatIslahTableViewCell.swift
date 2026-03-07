//
//  DawatIslahTableViewCell.swift
//  JDMS
//
//  Created by Moin Janjua on 14/12/2025.
//

import UIKit

import UIKit

class DawatIslahTableViewCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var uploadDate: UILabel!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var descriptionlb: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var iconView: UIView!
    @IBOutlet weak var bgView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        roundCorneView(view: iconView)
        addDropShadow(to: bgView)
    }

    func configure(with model: DawatPDF) {
        title.text = model.title
        uploadDate.text = "📅 \(model.uploadDate)"
        category.text = model.category
        descriptionlb.text = model.description
        //iconImage.image = UIImage(named: model.icon)
    }
}

