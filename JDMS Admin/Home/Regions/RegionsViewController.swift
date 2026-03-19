//
//  RegionsViewController.swift
//  JDMS Admin
//
//  Created by Moin Janjua on 04/01/2026.
//

import UIKit
import SideMenu
import NVActivityIndicatorView

class RegionsViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var addbtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var nodatImage: UIImageView!
    @IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!

    // Data Storage
    var regions: [Region] = []
    var filteredRegions: [Region] = []
    private var districtsByRegion: [Int: [District]] = [:]
    private var expandedRegionIds: Set<Int> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchRegionsList()
        
        let canManage = PermissionManager.shared.canPerform(action: .manageGeography)
        addbtn.isHidden = !canManage
    }
    
    func setupUI() {
        searchbar.placeholder = "Search Regions"
        activityIndicatorView.type = .ballPulse
        activityIndicatorView.color = .systemGreen // Replace with your primaryColor
        roundCorner(button: addbtn)
        addDropShadow(to: addbtn)
        
        tableView.delegate = self
        tableView.dataSource = self
        searchbar.delegate = self
        nodatImage.isHidden = true
    }

    // 1. Initial Load: Fetch Regions Only
    func fetchRegionsList() {
        activityIndicatorView.startAnimating()
        nodatImage.isHidden = true
        
        APIClient.shared.getAllRegions(page: 1) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicatorView.stopAnimating()
                switch result {
                case .success(let response):
                    if response.isSuccess {
                            self?.regions = response.data ?? []
                            self?.filteredRegions = self?.regions ?? [] // Initialize filtered list
                            self?.tableView.reloadData()
                            self?.updateNoDataState()
                        }
                case .failure(let error):
                    self?.nodatImage.isHidden = false
                    self?.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }

    // 2. Secondary Load: Fetch Districts for a specific Region ID
    func fetchDistricts(for regionId: Int, in section: Int) {
        activityIndicatorView.startAnimating()
        
        APIClient.shared.getAllDistricts { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicatorView.stopAnimating()
                switch result {
                case .success(let allDistricts):
                    // FILTER LOCALLY: Only keep districts for this region
                    let relevantDistricts = allDistricts.filter { $0.regionId == regionId }
                    
                    // Save filtered results to your dictionary
                    self?.districtsByRegion[regionId] = relevantDistricts
                    
                    self?.expandedRegionIds.insert(regionId)
                    self?.tableView.reloadSections(IndexSet(integer: section), with: .fade)
                    
                case .failure(let error):
                    self?.handleAPIError(error)
                }
            }
        }
    }
    
    func updateNoDataState() {
        let hasNoData = filteredRegions.isEmpty
        nodatImage.isHidden = !hasNoData
        tableView.isHidden = hasNoData
    }
    
    @IBAction func openMenu(_ sender: UIButton)
    {
         let Menu = storyboard?.instantiateViewController(withIdentifier:"SideMenuNavigation") as? SideMenuNavigationController
         Menu?.leftSide = true
         Menu?.settings = makeSettings()
         SideMenuManager.default.leftMenuNavigationController = Menu
         present(Menu!, animated: true, completion: nil)

     }
    
    @IBAction func addBtn(_ sender: UIButton) {

        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "AddRegionsViewController") as! AddRegionsViewController
        newViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        newViewController.modalTransitionStyle = .crossDissolve
        self.present(newViewController, animated: true, completion: nil)

       }
    
    
}

// MARK: - TableView Handling
extension RegionsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return filteredRegions.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let region = filteredRegions[section] // Use filtered here
            if expandedRegionIds.contains(region.id) {
                let count = districtsByRegion[region.id]?.count ?? 0
                return count == 0 ? 1 : count
            }
            return 0
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let region = filteredRegions[section]
        let isExpanded = expandedRegionIds.contains(region.id)
        
        // REDUCED height from 55 to 52 for a tighter fit
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 52))
        containerView.backgroundColor = .clear
        
        // ADJUSTED y from 5 to 2 to move the card up
        let headerCard = UIView(frame: CGRect(x: 10, y: 2, width: tableView.frame.width - 20, height: 48))
        headerCard.backgroundColor = .systemBackground
        headerCard.layer.cornerRadius = 10
        headerCard.tag = section
        
        // ... rest of your styling (shadows, labels, etc.) ...
        // Ensure labels and arrows are centered in the new 48pt height
        let label = UILabel(frame: CGRect(x: 15, y: 0, width: headerCard.frame.width - 60, height: 48))
        label.text = region.name
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        headerCard.addSubview(label)
        
        let arrow = UIImageView(frame: CGRect(x: headerCard.frame.width - 35, y: 14, width: 20, height: 20))
        arrow.image = UIImage(systemName: isExpanded ? "chevron.up" : "chevron.down")
        arrow.contentMode = .scaleAspectFit
        arrow.tintColor = .systemGray2
        headerCard.addSubview(arrow)

        containerView.addSubview(headerCard)
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleSectionTap(_:)))
        headerCard.addGestureRecognizer(tap)
        
        return containerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 52
    }



    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! regionsTableViewCell
        let regionId = filteredRegions[indexPath.section].id
        
        if let districts = districtsByRegion[regionId], !districts.isEmpty {
            let district = districts[indexPath.row]
            cell.districtlb.text = "   📍 \(district.name)"
            cell.districtlb.textColor = .label
        } else {
            cell.districtlb.text = "No districts found in this region"
            cell.districtlb.textColor = .secondaryLabel
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let regionId = filteredRegions[indexPath.section].id
        
        // 1. Get the selected district from your dictionary
        guard let districts = districtsByRegion[regionId], !districts.isEmpty else { return }
        let selectedDistrict = districts[indexPath.row]
        
        // 2. Instantiate the detail view controller
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let nextVC = storyBoard.instantiateViewController(withIdentifier: "ConstituencyDetailViewController") as? ConstituencyDetailViewController {
            
            // 3. PASS THE DATA
            nextVC.districtId = selectedDistrict.id
            
            // 4. Present it (Match the style you used for AddRegions)
            nextVC.modalPresentationStyle = .fullScreen
            nextVC.modalTransitionStyle = .crossDissolve
            self.present(nextVC, animated: true, completion: nil)
        }
    }

    @objc func handleSectionTap(_ gesture: UITapGestureRecognizer) {
        guard let section = gesture.view?.tag else { return }
        let regionId = filteredRegions[section].id
        
        if expandedRegionIds.contains(regionId) {
            // Collapse
            expandedRegionIds.remove(regionId)
            tableView.reloadSections(IndexSet(integer: section), with: .fade)
        } else {
            // Expand: Check if data exists locally first
            if districtsByRegion[regionId] != nil {
                expandedRegionIds.insert(regionId)
                tableView.reloadSections(IndexSet(integer: section), with: .fade)
            } else {
                // Fetch from API
                fetchDistricts(for: regionId, in: section)
            }
        }
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredRegions = regions
        } else {
            filteredRegions = regions.filter { region in
                return region.name.lowercased().contains(searchText.lowercased())
            }
        }
        tableView.reloadData()
        updateNoDataState()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}
