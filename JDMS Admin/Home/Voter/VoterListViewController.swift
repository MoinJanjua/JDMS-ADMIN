//
//  VoterListViewController.swift
//  JDMS Admin
//
//  Created by Moin Janjua on 18/01/2026.
//


import UIKit
import SideMenu
import NVActivityIndicatorView

class VoterListViewController: UIViewController {

    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var addbtn: UIButton!
    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!
    
    // Pagination & Search Variables
    var voterList: [MemberVoteRecord] = []
    var currentPage = 1
    var isFetching = false
    var hasMoreData = true
    var currentSearchText = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetAndLoad() // Refresh list when coming back from Edit/Add
    }
    
    func setupUI() {
        tv.delegate = self
        tv.dataSource = self
        searchbar.delegate = self
        tv.separatorStyle = .none
        
        roundCorner(button: addbtn)
        addbtn.setTitle("", for: .normal)
        
        activityIndicatorView.type = .ballPulseSync
        activityIndicatorView.color = .systemGreen
    }

    // MARK: - Logic for Search & Pagination
    func resetAndLoad() {
        currentPage = 1
        voterList = []
        hasMoreData = true
        loadVotingRecords()
    }

    func loadVotingRecords() {
        // Prevent duplicate calls or calling when no more data exists
        guard !isFetching && hasMoreData else { return }
        
        isFetching = true
        if currentPage == 1 {
            self.activityIndicatorView.isHidden = false
            self.activityIndicatorView.startAnimating()
        }

        // Setup Filters based on SearchBar text
        var filters = MemberVoteFilters()
        if !currentSearchText.isEmpty {
            filters.memberFullName = currentSearchText
            // You could also assign to filters.memberCNIC if you detect numbers
        }
        
        APIClient.shared.fetchAllMemberVotes(page: currentPage, filters: filters) { [weak self] result in
            DispatchQueue.main.async {
                self?.isFetching = false
                self?.activityIndicatorView.stopAnimating()
                self?.activityIndicatorView.isHidden = true
                
                switch result {
                case .success(let newRecords):
                    if newRecords.isEmpty {
                        self?.hasMoreData = false
                    } else {
                        self?.voterList.append(contentsOf: newRecords)
                        self?.currentPage += 1
                        self?.tv.reloadData()
                    }
                    
                case .failure(let error):
                    self?.handleAPIError(error)
                }
            }
        }
    }

    // MARK: - Actions
    @IBAction func openMenu(_ sender: UIButton) {
        let Menu = storyboard?.instantiateViewController(withIdentifier:"SideMenuNavigation") as? SideMenuNavigationController
        Menu?.leftSide = true
        Menu?.settings = makeSettings()
        SideMenuManager.default.leftMenuNavigationController = Menu
        present(Menu!, animated: true)
    }
    
    @IBAction func addbtn(_ sender: UIButton) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "AddVoterDetailsViewController") as! AddVoterDetailsViewController
        newViewController.modalPresentationStyle = .fullScreen
        newViewController.modalTransitionStyle = .crossDissolve
        self.present(newViewController, animated: true, completion: nil)
    }
}

// MARK: - Search Bar Delegate
extension VoterListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // We use a small delay (debounce) so we don't spam the API for every letter
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(triggerSearch), object: nil)
        self.currentSearchText = searchText
        self.perform(#selector(triggerSearch), with: nil, afterDelay: 0.5)
    }
    
    @objc func triggerSearch() {
        resetAndLoad()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - TableView Extensions
extension VoterListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return voterList.count
    }

    // Detect when user reached the bottom for Pagination
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.height * 1.5 {
            loadVotingRecords()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 112
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! VoterTableViewCell
        let record = voterList[indexPath.row]
        
        cell.namelb.text = record.member?.fullName ?? "No Name"
        cell.Fathernamelb.text = "Father: \(record.member?.fatherName ?? "N/A")"
        cell.cniclb.text = "CNIC: \(record.member?.cnic ?? "N/A")"
        cell.voterIDlb.text = "Voter ID: \(record.voterId ?? "N/A")"
        cell.pollingStationlb.text = record.pollingStation ?? "N/A"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let voter = voterList[indexPath.row]
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "VoterDetailsViewController") as! VoterDetailsViewController
        newViewController.modalPresentationStyle = .fullScreen
        newViewController.voterList = voter
        newViewController.modalTransitionStyle = .crossDissolve
        self.present(newViewController, animated: true, completion: nil)
    }
}
