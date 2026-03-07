//
//  HomeViewController.swift
//  JDMS Admin
//
//  Created by Moin Janjua on 28/12/2025.
//

import UIKit
import SideMenu
import Charts

var sideMenu: SideMenuNavigationController?
class HomeViewController: UIViewController {

    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var bg1: UIView!
    @IBOutlet weak var bg2: UIView!
    @IBOutlet weak var bg3: UIView!
    @IBOutlet weak var bg4: UIView!
    


     override func viewDidLoad() {
         super.viewDidLoad()
         addDropShadow(to: bg1)
         addDropShadow(to: bg2)
         addDropShadow(to: bg3)
         addDropShadow(to: bg4)
         
         setupPieChart()
         loadDummyData()

     }

    
    func setupPieChart() {
        pieChartView.usePercentValuesEnabled = false
            pieChartView.drawHoleEnabled = true
            pieChartView.holeRadiusPercent = 0.4
            pieChartView.transparentCircleRadiusPercent = 0.45
            pieChartView.chartDescription.enabled = false
            pieChartView.legend.enabled = true
            pieChartView.rotationEnabled = true
            pieChartView.entryLabelColor = .black
            pieChartView.entryLabelFont = .systemFont(ofSize: 12)
        }

        // MARK: - Dummy Data
        func loadDummyData() {

            let totalMembers = 500
            let verifiedMembers = 320
            let nonVerifiedMembers = 180
            let regions = 50

            let entries = [
                PieChartDataEntry(value: Double(totalMembers), label: "Total Members"),
                PieChartDataEntry(value: Double(verifiedMembers), label: "Verified Members"),
                PieChartDataEntry(value: Double(nonVerifiedMembers), label: "Non-Verified Members"),
                PieChartDataEntry(value: Double(regions), label: "Regions")
            ]

            let dataSet = PieChartDataSet(entries: entries, label: "Members Statistics")

            dataSet.colors = [
                .systemBlue,
                .systemGreen,
                .systemRed,
                .systemOrange
            ]

            dataSet.valueTextColor = .black
            dataSet.valueFont = .systemFont(ofSize: 12)

            let data = PieChartData(dataSet: dataSet)

            let formatter = NumberFormatter()
            formatter.numberStyle = .percent
            formatter.maximumFractionDigits = 1
            formatter.multiplier = 1
            formatter.percentSymbol = "%"

            data.setValueFormatter(DefaultValueFormatter(formatter: formatter))

            pieChartView.data = data
            pieChartView.animate(xAxisDuration: 1.2, easingOption: .easeOutBack)
        }

     @IBAction func openMenu(_ sender: UIButton) {
         let Menu = storyboard?.instantiateViewController(withIdentifier:"SideMenuNavigation") as? SideMenuNavigationController
         Menu?.leftSide = true
         Menu?.settings = makeSettings()
         SideMenuManager.default.leftMenuNavigationController = Menu
         present(Menu!, animated: true, completion: nil)

     }
    
    
 }

 func makeSettings() -> SideMenuSettings
{
    let presentationStyle = SideMenuPresentationStyle.menuSlideIn
    
    presentationStyle.backgroundColor =  UIColor.black.withAlphaComponent(0.5)
    
    presentationStyle.presentingEndAlpha = 0.5
    var settings = SideMenuSettings()
    settings.menuWidth = 290.0
    settings.presentationStyle = presentationStyle
    return settings
}
