//
//  NotificationsTableViewCell.swift
//  JDMS Admin
//
//  Created by Moin Janjua on 12/01/2026.
//

import UIKit

class NotificationsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var bgView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // dotView.layer.cornerRadius = dotView.frame.height / 2
        
        addDropShadow(to: bgView)
    }
    
}


extension Date {
    func formattedString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy, hh:mm a"
        return formatter.string(from: self)
    }
}

