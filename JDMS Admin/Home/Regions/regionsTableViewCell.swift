//
//  regionsTableViewCell.swift
//  JDMS Admin
//
//  Created by Moin Janjua on 04/01/2026.
//

import UIKit

class regionsTableViewCell: UITableViewCell {

    @IBOutlet weak var districtlb: UILabel!
    @IBOutlet weak var regionlb: UILabel!
    @IBOutlet weak var ucCountlb: UILabel!
    @IBOutlet weak var constitutionCountlb: UILabel!
    @IBOutlet weak var wardCOuntlb: UILabel!
    @IBOutlet weak var bgView: UIView!

    func configure(with affiliation: Affiliation) {

        districtlb.text = affiliation.name
        regionlb.text = "AJK"   // static for now, dynamic later

        let constituencyCount = affiliation.constituencies.count

        let ucCount = affiliation.constituencies
            .flatMap { $0.unionCouncils }
            .count

        let wardCount = affiliation.constituencies
            .flatMap { $0.unionCouncils }
            .flatMap { $0.wards }
            .count

        constitutionCountlb.text = "Total Constituency : \(constituencyCount)"
        ucCountlb.text = "Total UnionCouncil : \(ucCount) ・ Total Ward : \(wardCount)"
        //wardCOuntlb.text =
    }
}

