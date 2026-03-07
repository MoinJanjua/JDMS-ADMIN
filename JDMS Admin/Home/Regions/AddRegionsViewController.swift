//
//  RegionsViewController.swift
//  JDMS Admin
//
//  Created by Moin Janjua on 29/12/2025.
//

import UIKit



class AddRegionsViewController: UIViewController {

    @IBOutlet weak var View1: UIView!
    @IBOutlet weak var View2: UIView!
    @IBOutlet weak var View3: UIView!
    @IBOutlet weak var View4: UIView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        addDropShadow(to: View1)
        addDropShadow(to: View2)
        addDropShadow(to: View3)
        addDropShadow(to: View4)
    
    }
    
    @IBAction func backbtnTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }

}
