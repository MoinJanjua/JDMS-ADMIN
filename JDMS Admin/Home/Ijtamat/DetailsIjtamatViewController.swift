//
//  DetailsIjtamatViewController.swift
//  JDMS Admin
//
//  Created by Moin Janjua on 11/01/2026.
//

import UIKit

class DetailsIjtamatViewController: UIViewController {

    @IBOutlet weak var categorylb: UILabel!
    @IBOutlet weak var datelb: UILabel!
    @IBOutlet weak var locationlb: UILabel!
    @IBOutlet weak var organizerlb: UILabel!
    @IBOutlet weak var speakerlb: UILabel!
    @IBOutlet weak var titlelb: UILabel!
    @IBOutlet weak var descriptionlb: UILabel!
    @IBOutlet weak var statuslb: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var statusBG: UIView!
    
    var event: EventRecord? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        organizerlb.font = .jameelNastaleeq(17)
        descriptionlb.font = .jameelNastaleeq(16)
        locationlb.font = .jameelNastaleeq(17)
        titlelb.font = .jameelNastaleeqBold(17, isBold: true)
        speakerlb.font = .jameelNastaleeqBold(17, isBold: true)
        categorylb.font = .jameelNastaleeq(15)
        
    titlelb.text = event?.title
    categorylb.text = event?.category
        if let startStr = event?.startDate {
            let startFormatted = formatServerDate(startStr)
            let endFormatted = formatServerDate(event?.endDate ?? "")
            datelb.text = "\(startFormatted) - \(endFormatted)"
        }
    locationlb.text = event?.location
    organizerlb.text = event?.organizedBy
    speakerlb.text = event?.speaker ?? "—"
    descriptionlb.text = event?.description
        
        let status = getEventStatus(start: event?.startDate, end: event?.endDate)
    statuslb.text = status.rawValue
    statusBG.backgroundColor = status.color
        
    //statusBG.backgroundColor = event?.status == "Upcoming" ? .systemGreen : .systemGray
    addDropShadow(to: bgView)
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func backbtnTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
}
