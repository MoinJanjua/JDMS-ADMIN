//
//  NotificationsDetailsViewController.swift
//  JDMS
//
//  Created by Moin Janjua on 25/12/2025.
//

import UIKit

class NotificationsDetailsViewController: UIViewController {

    @IBOutlet weak var titlelb: UILabel!
    @IBOutlet weak var desclb: UILabel!
    @IBOutlet weak var datelb: UILabel!
   
    
    var message = String()
    var titles = String()
    var date = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titlelb.text = titles
        desclb.text = message
        datelb.text = date
        
        titlelb.font = UIFont(
            name: "Jameel-Noori-Nastaleeq",
            size: 17
        )
        
        desclb.font = UIFont(
            name: "Jameel-Noori-Nastaleeq",
            size: 17
        )
        // Do any additional setup after loading the view.
    }
    
    @IBAction func backbtnTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
 

}
