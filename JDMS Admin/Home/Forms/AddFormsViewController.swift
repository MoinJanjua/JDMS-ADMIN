//
//  AddFormsViewController.swift
//  JDMS Admin
//
//  Created by Moin Janjua on 12/01/2026.
//

import UIKit


class AddFormsViewController: UIViewController {

    @IBOutlet weak var titlelb: UITextField!
    @IBOutlet weak var formtypelb: DropDown!
    @IBOutlet weak var orderlb: UITextField!
    @IBOutlet weak var questtypelb: DropDown!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDropDowns()
    }

    func setupDropDowns() {

        // Form Type Dropdown
        formtypelb.optionArray = ["Form A", "Form B"]
        formtypelb.placeholder = "Select Form Type"
        formtypelb.didSelect { selectedText, index, id in
            print("Selected Form Type:", selectedText)
        }

        // Question Type Dropdown
        questtypelb.optionArray = ["Select", "Date", "Options", "List"]
        questtypelb.placeholder = "Select Question Type"
        questtypelb.didSelect { selectedText, index, id in
            print("Selected Question Type:", selectedText)
        }
    }

    @IBAction func backbtnTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    
    @IBAction func SavebtnTapped(_ sender: UIButton) {
        
    }
}

