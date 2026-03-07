import UIKit
import SideMenu
import NVActivityIndicatorView

class IjtimatViewController: UIViewController {
    
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var addbtn: UIButton!
    @IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!
    
    // Updated to use the new API model
    private var eventsList: [EventRecord] = []
    
    var currentPage = 1
    var isFetching = false
    var hasMoreData = true
    let pageSize = 50 // Matching your Swagger default
    
    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        roundCorner(button: addbtn)
        setupTableView()
        setupActivityIndicator()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchEventsData(isRefresh: true)
    }
    
    private func setupTableView() {
        tv.delegate = self
        tv.dataSource = self
        tv.separatorStyle = .none
        
        // Add Pull to Refresh
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tv.refreshControl = refreshControl
    }
    
    func setupActivityIndicator() {
        activityIndicatorView.type = .ballRotate
        activityIndicatorView.color = primaryColor
        activityIndicatorView.padding = 0
        activityIndicatorView.isHidden = true
    }

    @objc private func refreshData() {
        fetchEventsData(isRefresh: true)
    }

    // MARK: - API Fetching
    private func fetchEventsData(isRefresh: Bool = false) {
        guard !isFetching else { return }
        
        if isRefresh {
            currentPage = 1
            hasMoreData = true
        }
        
        guard hasMoreData else { return }
        
        isFetching = true
        if isRefresh { refreshControl.beginRefreshing() }
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()

        APIClient.shared.fetchEvents(pageNumber: currentPage, pageSize: pageSize) { [weak self] result in
            DispatchQueue.main.async {
                self?.isFetching = false
                self?.refreshControl.endRefreshing()
                self?.activityIndicatorView.stopAnimating()
                self?.activityIndicatorView.isHidden = true
                
                switch result {
                case .success(let wrapper):
                    let newItems = wrapper.data
                    
                    // 1. Filter active items
                    let activeItems = newItems.filter { $0.isActive == true }
                    
                    if isRefresh {
                        self?.eventsList = activeItems
                    } else {
                        self?.eventsList.append(contentsOf: activeItems)
                    }
                    
                    // 2. Sort the entire list by startDate
                    // We want the most recent/closest upcoming events at the top
                    self?.eventsList.sort { (event1, event2) -> Bool in
                        let status1 = getEventStatus(start: event1.startDate, end: event1.endDate)
                        let status2 = getEventStatus(start: event2.startDate, end: event2.endDate)
                        
                        // Custom priority: Ongoing = 0, Today = 1, Upcoming = 2, Past = 3
                        let priority: [EventStatus: Int] = [.ongoing: 0, .today: 1, .upcoming: 2, .past: 3]
                        
                        return (priority[status1] ?? 4) < (priority[status2] ?? 4)
                    }
                    self?.hasMoreData = wrapper.paginationResponseDetails.hasNextPage
                    self?.currentPage += 1
                    self?.tv.reloadData()
                    
                case .failure(let error):
                    print("Error fetching events: \(error.localizedDescription)")
                    let nsError = error as NSError
                    if nsError.code == 401 {
                        self?.showAlertWithButtons(title: "Session Expired", message: "Please login again.", okTitle: "Login", cancelTitle: nil) {
                            AppNavigator.navigateToLogin()
                        }
                    } else {
                        self?.showAlert(title: "Error", message: error.localizedDescription)
                    }
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
        present(Menu!, animated: true, completion: nil)
    }
    
    @IBAction func addbtn(_ sender: UIButton) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "AddEventsViewController") as! AddEventsViewController
        newViewController.modalPresentationStyle = .fullScreen
        newViewController.modalTransitionStyle = .crossDissolve
        self.present(newViewController, animated: true, completion: nil)
    }
}

// MARK: - TableView Methods
extension IjtimatViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventsList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 102 // Increased height for event details
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! IjtamatTableViewCell
        
        let event = eventsList[indexPath.row]
        
        cell.titlelb.text = event.title
        cell.descriptionlblb.text = event.description
        
        // 1. Format and display the dates
        if let startStr = event.startDate {
            let startFormatted = formatServerDate(startStr)
            let endFormatted = formatServerDate(event.endDate ?? "")
            cell.datelb.text = "\(startFormatted) - \(endFormatted)"
        }
        
        // 2. Determine and apply status
        let status = getEventStatus(start: event.startDate, end: event.endDate)
        
        cell.statuslb.text = status.rawValue
        cell.statusBG.backgroundColor = status.color
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let event = eventsList[indexPath.row]
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "DetailsIjtamatViewController") as! DetailsIjtamatViewController
        
        // Pass the new model type
        newViewController.event = event
        
        newViewController.modalPresentationStyle = .fullScreen
        newViewController.modalTransitionStyle = .crossDissolve
        self.present(newViewController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // 1. DELETE ACTION
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completionHandler) in
            guard let self = self else { return }
            let event = self.eventsList[indexPath.row]
            
            self.activityIndicatorView.isHidden = false
            self.activityIndicatorView.startAnimating()
            
            APIClient.shared.deleteEvent(id: event.id) { result in
                DispatchQueue.main.async {
                    self.activityIndicatorView.stopAnimating()
                    self.activityIndicatorView.isHidden = true
                    
                    switch result {
                    case .success(let success):
                        if success {
                            self.eventsList.remove(at: indexPath.row)
                            tableView.deleteRows(at: [indexPath], with: .automatic)
                        }
                    case .failure(let error):
                        self.showAlert(title: "Error", message: error.localizedDescription)
                    }
                    completionHandler(true)
                }
            }
        }
        
        // 2. EDIT ACTION
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] (_, _, completionHandler) in
            guard let self = self else { return }
            let eventToEdit = self.eventsList[indexPath.row]
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            if let editVC = storyBoard.instantiateViewController(withIdentifier: "AddEventsViewController") as? AddEventsViewController {
                
                // Pass the selected event to the controller
                editVC.existingEvent = eventToEdit
                
                editVC.modalPresentationStyle = .fullScreen
                editVC.modalTransitionStyle = .crossDissolve
                self.present(editVC, animated: true, completion: nil)
            }
            
            completionHandler(true)
        }
        
        // Set Edit background color to Blue or Orange to distinguish from Delete
        editAction.backgroundColor = .systemBlue
        
        // 3. RETURN BOTH ACTIONS
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
    
    

    // Pagination: Trigger fetch when reaching bottom
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.height * 1.5 {
            if !isFetching && hasMoreData {
                fetchEventsData()
            }
        }
    }
}
