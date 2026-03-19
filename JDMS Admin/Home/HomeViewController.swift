//
//  HomeViewController.swift
//  JDMS Admin
//
//  Created by Moin Janjua on 28/12/2025.
//

import UIKit
import SideMenu
import Charts
import NVActivityIndicatorView // Assuming you use this for the loader

class HomeViewController: UIViewController {

    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var bg1: UIView!
    @IBOutlet weak var bg2: UIView!
    @IBOutlet weak var bg3: UIView!
    @IBOutlet weak var bg4: UIView!
    
    // Add these IBOutlets to your labels in Storyboard
    @IBOutlet weak var totalMembersLabel: UILabel!
    @IBOutlet weak var verifiedMembersLabel: UILabel!
    @IBOutlet weak var nonVerifiedMembersLabel: UILabel!
    @IBOutlet weak var totalVotersLabel: UILabel!
    
    @IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicatorView.type = .ballPulse
        activityIndicatorView.color = primaryColor
        setupUI()
        setupPieChart()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchDashboardStats()
    }

    func setupUI() {
        addDropShadow(to: bg1)
        addDropShadow(to: bg2)
        addDropShadow(to: bg3)
        addDropShadow(to: bg4)
        
        // Hide chart until data is ready
        pieChartView.noDataText = "Loading statistics..."
    }

    func setupPieChart() {
        pieChartView.usePercentValuesEnabled = true // Changed to true for better visual
        pieChartView.drawHoleEnabled = true
        pieChartView.holeRadiusPercent = 0.4
        pieChartView.transparentCircleRadiusPercent = 0.45
        pieChartView.chartDescription.enabled = false
        pieChartView.legend.enabled = true
        pieChartView.rotationEnabled = true
        pieChartView.entryLabelColor = .black
        pieChartView.entryLabelFont = .systemFont(ofSize: 12, weight: .bold)
    }

    // MARK: - API Integration
    func fetchDashboardStats() {
        // Start loading animation
        self.activityIndicatorView?.startAnimating()
        
        APIClient.shared.getDashboardStats { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicatorView?.stopAnimating()
                
                switch result {
                case .success(let stats):
                    self?.updateUI(with: stats)
                case .failure(let error):
                    self?.handleAPIError(error)
                }
            }
        }
    }

    func updateUI(with stats: DashboardStats) {
        // 1. Update Labels
        totalMembersLabel.text = "\(stats.totalMembers)"
        verifiedMembersLabel.text = "\(stats.verifiedMembers)"
        nonVerifiedMembersLabel.text = "\(stats.nonVerifiedMembers)"
        totalVotersLabel.text = "\(stats.totalVoters)"

        // 2. Update Pie Chart
        let entries = [
            PieChartDataEntry(value: Double(stats.totalMembers), label: "members"),
            PieChartDataEntry(value: Double(stats.verifiedMembers), label: "Verified"),
            PieChartDataEntry(value: Double(stats.nonVerifiedMembers), label: "Non-Verified"),
            PieChartDataEntry(value: Double(stats.totalVoters), label: "Voters")
        ]

        let dataSet = PieChartDataSet(entries: entries, label: "")
        dataSet.colors = [.systemYellow,.systemGreen, .systemRed, .systemBlue]
        dataSet.sliceSpace = 2
        dataSet.valueTextColor = .white
        dataSet.valueFont = .systemFont(ofSize: 11, weight: .bold)

        let data = PieChartData(dataSet: dataSet)
        
        // Formatting to show percentages on the chart
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 1
        formatter.multiplier = 1.0
        data.setValueFormatter(DefaultValueFormatter(formatter: formatter))

        pieChartView.data = data
        pieChartView.animate(xAxisDuration: 1.0, easingOption: .easeInOutQuad)
    }

    @IBAction func openMenu(_ sender: UIButton) {
        let Menu = storyboard?.instantiateViewController(withIdentifier:"SideMenuNavigation") as? SideMenuNavigationController
        Menu?.leftSide = true
        Menu?.settings = makeSettings()
        SideMenuManager.default.leftMenuNavigationController = Menu
        present(Menu!, animated: true, completion: nil)
    }
}
