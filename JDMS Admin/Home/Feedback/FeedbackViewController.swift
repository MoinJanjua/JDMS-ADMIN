import UIKit
import SideMenu
import NVActivityIndicatorView

class FeedbackViewController: UIViewController {

    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var segmentedctrl: UISegmentedControl!
    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!
    
    // Using the live API model instead of dummy structs
    var complaints: [ComplaintRecord] = []
    var filteredComplaints: [ComplaintRecord] = []
    var userCache: [Int: String] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tv.delegate = self
        tv.dataSource = self
        searchbar.delegate = self
        
        setupLoader()
        fetchFeedbackData()
    }
    
    func setupLoader() {
        activityIndicatorView.type = .ballRotate
        activityIndicatorView.color = primaryColor // Ensure primaryColor is defined globally
        activityIndicatorView.padding = 0
    }
    
    func fetchFeedbackData() {
        self.activityIndicatorView.startAnimating()
        self.activityIndicatorView.isHidden = false
        
        // Calling the API function from APIClient
        APIClient.shared.fetchAllComplaints(page: 1) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicatorView.stopAnimating()
                self?.activityIndicatorView.isHidden = true
                
                switch result {
                case .success(let records):
                    self?.complaints = records
                    self?.applyFilters() // Apply initial segment/search filters
                case .failure(let error):
                    if error.localizedDescription.contains("401") {
                        self?.handleAPIError(error)
                    } else {
                        self?.showAlert(title: "Error!", message: error.localizedDescription)
                    }
                    // Optional: show error alert
                }
            }
        }
    }
    
    func applyFilters() {
        let selectedIndex = segmentedctrl.selectedSegmentIndex
        let searchText = searchbar.text?.lowercased() ?? ""

        // Step 1: Filter by Segmented Control (Type)
        var tempData: [ComplaintRecord] = []

        if selectedIndex == 0 {
            tempData = complaints
        } else if selectedIndex == 1 {
            tempData = complaints.filter { $0.type == "1" }
        } else {
            tempData = complaints.filter { $0.type == "2" }
        }

        // Step 2: Filter by Search (Subject, Category, OR Member Name)
        if !searchText.isEmpty {
            tempData = tempData.filter { complaint in
                // Check Subject
                let matchSubject = complaint.subject?.lowercased().contains(searchText) ?? false
                // Check Category
                let matchCategory = complaint.category?.lowercased().contains(searchText) ?? false
                
                // NEW: Check User Name from Cache
                let userId = complaint.memberId ?? 0
                let cachedName = userCache[userId]?.lowercased() ?? ""
                let matchName = cachedName.contains(searchText)
                
                return matchSubject || matchCategory || matchName
            }
        }

        filteredComplaints = tempData
        tv.reloadData()
    }

    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        applyFilters()
    }

    @IBAction func openMenu(_ sender: UIButton) {
        let Menu = storyboard?.instantiateViewController(withIdentifier:"SideMenuNavigation") as? SideMenuNavigationController
        Menu?.leftSide = true
        Menu?.settings = makeSettings()
        SideMenuManager.default.leftMenuNavigationController = Menu
        present(Menu!, animated: true)
    }
}

// MARK: - TableView Extensions
extension FeedbackViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredComplaints.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FeedbackTableViewCell
        let data = filteredComplaints[indexPath.row]

        // 1. Text & UI Setup
        cell.messagelb.text = data.details
       // cell.datelb.text = formatDate(data.createdAt) // Using a helper for the date
        
        if data.type == "1" {
            cell.comaplinView.backgroundColor = .systemRed
            cell.complaintype.text = "Complaint"
            cell.suggestionimage.image = UIImage(named: "complain")
        } else {
            cell.comaplinView.backgroundColor = .systemGreen
            cell.complaintype.text = "Feedback"
            cell.suggestionimage.image = UIImage(named: "suggestion")
        }

        // 2. Fetch User Name using memberId
        let userId = data.memberId ?? 0
        let dateStr = formatDate(data.createdAt) // Using the helper from before

        if let cachedName = userCache[userId] {
            // ✅ The professional "Pill" style string
            cell.submittedBylb.text = "👤 \(cachedName) • \(dateStr)"
        } else if userId != 0 {
            cell.submittedBylb.text = "👤 Loading... • \(dateStr)"
            
            APIClient.shared.getUserProfile(id: userId) { [weak self] result in
                if case .success(let response) = result, let name = response.data?.name {
                    self?.userCache[userId] = name
                    DispatchQueue.main.async {
                        // Use .fade for a smoother visual update than .none
                        tableView.reloadRows(at: [indexPath], with: .fade)
                    }
                } else {
                    self?.userCache[userId] = "System User"
                }
            }
        } else {
            cell.submittedBylb.text = "👤 Anonymous • \(dateStr)"
        }

        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 98 // Increased slightly to fit API details
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = filteredComplaints[indexPath.row]
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "DetailsFeedbackViewController") as! DetailsFeedbackViewController
        newViewController.modalPresentationStyle = .fullScreen
        
        // Update your Details view to accept 'ComplaintRecord' instead of 'Complaint'
          newViewController.complaints = data
        
        newViewController.modalTransitionStyle = .crossDissolve
        self.present(newViewController, animated: true, completion: nil)
    }
}

// MARK: - SearchBar Delegate
extension FeedbackViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        applyFilters()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
