//
//  FormsViewController.swift
//  JDMS Admin
//
//  Created by Moin Janjua on 29/12/2025.
//

import UIKit
import SideMenu

class FormsViewController: UIViewController {
    
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var addbtn: UIButton!
    
    var questionsList: [QuestionModal] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tv.dataSource = self
        tv.delegate = self
        tv.tableFooterView = UIView()
        roundCorner(button: addbtn)
        
        loadDummyData()
    }
    
    
    func loadDummyData() {
        questionsList = [
            QuestionModal(questionTitle: "صارف کی رائے", formType: "سروے فارم", questionOrder: 1, questionType: "ملٹی پل چوائس"),
            QuestionModal(questionTitle: "سروس فیڈبیک", formType: "فیڈبیک فارم", questionOrder: 2, questionType: "مختصر جواب"),
            QuestionModal(questionTitle: "پروڈکٹ ریویو", formType: "ریویو فارم", questionOrder: 3, questionType: "ریٹنگ سسٹم")
        ]
        
        tv.reloadData()
    }
    
    @IBAction func addbtn(_ sender: UIButton) {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "AddFormsViewController") as! AddFormsViewController
        newViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        
        newViewController.modalTransitionStyle = .crossDissolve
        self.present(newViewController, animated: true, completion: nil)
    }
    
    
    @IBAction func openMenu(_ sender: UIButton) {
        let Menu = storyboard?.instantiateViewController(withIdentifier:"SideMenuNavigation") as? SideMenuNavigationController
        Menu?.leftSide = true
        Menu?.settings = makeSettings()
        SideMenuManager.default.leftMenuNavigationController = Menu
        present(Menu!, animated: true, completion: nil)
        
    }
    
}


extension FormsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questionsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "cell",
            for: indexPath
        ) as! FormsTableViewCell
        
        let data = questionsList[indexPath.row]
        
        cell.titlelb.text = "عنوان: \(data.questionTitle)"
        cell.formtypelb.text = "فارم کی قسم: \(data.formType)"
        
        cell.questtypelb.text = "سوال کی قسم: \(data.questionType)"
        
        cell.titlelb.font = UIFont(
            name: "Jameel-Noori-Nastaleeq",
            size: 17
        )
        
        cell.formtypelb.font = UIFont(
            name: "Jameel-Noori-Nastaleeq",
            size: 17
        )
        
        
        cell.questtypelb.font = UIFont(
            name: "Jameel-Noori-Nastaleeq",
            size: 17
        )
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let data = questionsList[indexPath.row]
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "DetailsFormsViewController") as! DetailsFormsViewController
        newViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        newViewController.questionData = data
        newViewController.modalTransitionStyle = .crossDissolve
        self.present(newViewController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
