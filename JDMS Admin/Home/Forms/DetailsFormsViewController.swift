//
//  DetailsFormsViewController.swift
//  JDMS Admin
//
//  Created by Moin Janjua on 12/01/2026.
//

import UIKit

class DetailsFormsViewController: UIViewController {

    @IBOutlet weak var titlelb: UILabel!
    @IBOutlet weak var formtypelb: UILabel!
    @IBOutlet weak var orderlb: UILabel!
    @IBOutlet weak var questtypelb: UILabel!

    // Data Object
    var questionData: QuestionModal?

    override func viewDidLoad() {
        super.viewDidLoad()
        showData()
    }

    func showData() {
        guard let data = questionData else { return }

        titlelb.text = "عنوان: \(data.questionTitle)"
        formtypelb.text = "فارم کی قسم: \(data.formType)"
        orderlb.text = "سوال نمبر: \(data.questionOrder)"
        questtypelb.text = "سوال کی قسم: \(data.questionType)"
    }

    @IBAction func backbtnTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

