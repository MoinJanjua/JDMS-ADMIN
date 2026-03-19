//
//  MembersViewController.swift
//  JDMS Admin
//
//  Created by Moin Janjua on 29/12/2025.
//

import UIKit
import SideMenu
import SDWebImage // Use this to load images from URLs
import NVActivityIndicatorView


class MembersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addbtn: UIButton!
    @IBOutlet weak var districtDD: DropDown!
    @IBOutlet weak var memeberDD: DropDown! // This can be used for Gender or Status
    @IBOutlet weak var educationsDD: DropDown!
    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!
    
    // Data Storage
    var allMembers: [Member] = []
    var currentFilters = MemberFilters()
    var districts: [District] = []
    var currentPage = 1
    var isFetching = false
    var hasMoreData = true
    let pageSize = 50

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDropDowns()
        fetchDistricts()
        activityIndicatorView.type = .ballPulseSync
        activityIndicatorView.color = .systemGreen
        activityIndicatorView.isHidden = true // Keep it hidden until needed
        NotificationCenter.default.addObserver(self, selector: #selector(fetchMembers), name: NSNotification.Name("MemberDeleted"), object: nil)
        let canEdit = PermissionManager.shared.canPerform(action: .editMembers)
        addbtn.isHidden = !canEdit
    }
    
    func setupUI() {
        tableView.delegate = self
        tableView.dataSource = self
        searchbar.delegate = self
        tableView.tableFooterView = UIView()
        roundCorner(button: addbtn)
        addDropShadow(to: addbtn)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        fetchMembers()
    }
    
    // MARK: - API Calls
    
    @objc func fetchMembers(isRefresh: Bool = true) {
        // Prevent duplicate calls or fetching if we reached the end
        guard !isFetching && (isRefresh || hasMoreData) else { return }
        
        isFetching = true
        if isRefresh {
            currentPage = 1
            hasMoreData = true
        }

        // Show loader only on first fetch
        if currentPage == 1 {
            DispatchQueue.main.async { startLoading(view: self.activityIndicatorView) }
        }

        // Pass the page number to the API filters
        var filters = currentFilters
        // Assuming you add 'page' and 'pageSize' to your MemberFilters struct
        DispatchQueue.main.async {
            self.activityIndicatorView.startAnimating()
        }
        

        APIClient.shared.getAllMembers(filters: filters, page: currentPage, size: pageSize) { [weak self] result in
            DispatchQueue.main.async {
                self?.isFetching = false
                self?.activityIndicatorView.stopAnimating()
                
                switch result {
                case .success(let members):
                    if isRefresh {
                        self?.allMembers = members
                    } else {
                        self?.allMembers.append(contentsOf: members)
                    }
                    
                    // If the server returns fewer items than the page size, we reached the end
                    self?.hasMoreData = members.count == self?.pageSize
                    self?.currentPage += 1
                    self?.tableView.reloadData()
                    
                case .failure(let error):
                    let nsError = error as NSError
                    
                    // Check if status code is 401 (Unauthorized)
                    if nsError.code == 401 {
                        self?.showAlertWithButtons(
                            title: "Session Expired",
                            message: "Your session has timed out. Please login again to continue.",
                            okTitle: "Login",
                            cancelTitle: nil // User MUST login, so we don't need a cancel button
                        ) {
                            // This closure runs when the user taps "Login"
                            AppNavigator.navigateToLogin()
                        }
                    } else {
                        // Handle all other errors (No internet, 500 server error, etc.)
                        self?.showAlert(title: "Error!", message: error.localizedDescription)
                    }
                }
            }
        }
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        // Trigger when user is 100 pixels from the bottom
        if offsetY > contentHeight - scrollView.frame.height - 100 {
            if !isFetching && hasMoreData {
                fetchMembers(isRefresh: false)
            }
        }
    }
    
    func fetchDistricts() {
        APIClient.shared.getAllDistricts { [weak self] result in
            if case .success(let list) = result {
                self?.districts = list
                self?.districtDD.optionArray = list.map { $0.name }
            }
        }
    }
    
    @IBAction func removeFilterbtnPressed(_ sender: UIButton) {
        // 1. Reset the filter object to empty values
        currentFilters = MemberFilters()
        
        // 2. Clear the UI components
        searchbar.text = ""
        districtDD.text = ""
        educationsDD.text = ""
        memeberDD.text = ""
        
        // 3. Resign keyboard if active
        searchbar.resignFirstResponder()
        
        // 4. Fetch all data again from the server
        fetchMembers(isRefresh: true)
    }
    
    
    
    @IBAction func openMenu(_ sender: UIButton) {
        
        let menu = storyboard?.instantiateViewController(withIdentifier: "SideMenuNavigation") as? SideMenuNavigationController
        menu?.leftSide = true
        menu?.settings = makeSettings()
        SideMenuManager.default.leftMenuNavigationController = menu
        self.present(menu!, animated: true, completion: nil)
        
    }
    
    @IBAction func addmemberBtn(_ sender: UIButton) {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "AddMemberViewController") as! AddMemberViewController
        newViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        newViewController.modalTransitionStyle = .crossDissolve
        self.present(newViewController, animated: true, completion: nil)
        
    }

    // MARK: - Search & Filters
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        currentFilters.searchTerm = searchText
        fetchMembers(isRefresh: true)
    }

    func setupDropDowns() {
        // District Filter
        districtDD.didSelect { [weak self] (selectedText, index, id) in
            self?.currentFilters.city = selectedText // Using city as proxy for district if needed
            self?.fetchMembers()
        }
        
        // Education Filter (Static)
        educationsDD.optionArray = ["Matric", "Intermediate", "Bachelors", "Masters", "PhD"]
        educationsDD.didSelect { [weak self] (selectedText, index, id) in
            // If the API supports education filter, add it to MemberFilters struct
            // For now, we use searchTerm as a fallback
            self?.currentFilters.searchTerm = selectedText
            self?.fetchMembers()
        }
        
        // Gender/Status Filter
        memeberDD.optionArray = ["Male", "Female", "Active", "Inactive"]
        memeberDD.didSelect { [weak self] (selectedText, index, id) in
            if selectedText == "Male" || selectedText == "Female" {
                self?.currentFilters.gender = selectedText
            } else {
                self?.currentFilters.membershipStatus = selectedText
            }
            self?.fetchMembers()
        }
    }

    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allMembers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? memberTableViewCell else {
            return UITableViewCell()
        }

        let member = allMembers[indexPath.row]
        cell.NameLb.text = member.fullName
        cell.FNameLb.text = "Father: \(member.fatherName)"
        cell.cityLb.text = "City: \(member.city)"
        cell.EducationLb.text = "Education: \(member.education)"
        
        if member.membershipStatus == "VERIFIED" {
            cell.veirfybutton.setTitle("Unverify", for: .normal)
            cell.veirfybutton.setTitleColor(.systemGreen, for: .normal)
            //cell.veirfybutton.backgroundColor = .systemGreen // Indicates a 'reversal' or 'warning' action
            cell.verifyView.backgroundColor = DimGreenColor
            cell.verifyView.layer.borderColor = UIColor(red: 52/255, green: 199/255, blue: 89/255, alpha: 1.0).cgColor
            cell.verifyView.layer.borderWidth = 1.0 // Show a small green indicator in your verifyView
            
            } else {
                cell.veirfybutton.setTitle("Verify", for: .normal)
                cell.veirfybutton.setTitleColor(.systemRed, for: .normal)
                cell.verifyView.backgroundColor = DimRedColor
                cell.verifyView.layer.borderColor =  UIColor(red: 255/255, green: 59/255, blue: 48/255, alpha: 1.0).cgColor
                cell.verifyView.layer.borderWidth = 1.0
            }
            
           
        
        let gender = member.gender?.lowercased() ?? "male"
            let placeholderName = (gender == "female") ? "userFemale" : "user 1"
            let placeholderImage = UIImage(named: placeholderName)
            
            // Set content mode based on gender for the placeholder
            cell.profileImageView.contentMode = (gender == "female") ? .scaleAspectFit : .scaleAspectFill

            // 2. Load Image
            let imagePath = member.imageUrl ?? ""
            if !imagePath.isEmpty, let url = URL(string: APIClient.shared.baseURL + imagePath) {
                // SDWebImage will replace the placeholder once the real image is ready
                cell.profileImageView.sd_setImage(with: url, placeholderImage: placeholderImage) { (image, error, cacheType, url) in
                    // Once the REAL image loads, switch to AspectFill for a professional look
                    if image != nil {
                        cell.profileImageView.contentMode = .scaleAspectFill
                    }
                }
            }
        else
        {
                // No path, just show placeholder
                cell.profileImageView.image = placeholderImage
        }
        
        cell.onVerifyTap = { [weak self] in
            let action = (member.membershipStatus == "VERIFIED") ? "Unverify" : "Verify"
            
            self?.showAlertWithButtons(title: "Confirm",
                                       message: "Do you want to \(action) this member?",
                                       okTitle: "Yes",
                                       cancelTitle: "No") {
                self?.toggleMemberStatus(member: member)
            }
        }

        return cell
    }
    
    func toggleMemberStatus(member: Member) {
        let newStatus = (member.membershipStatus == "VERIFIED") ? "NON_VERIFIED" : "VERIFIED"
        
        // Create the DTO with "Safe" defaults for required database fields
        let updatedData = MemberUpdateRequest(
            id: member.id ?? 0,
            fullName: member.fullName,
            urduName: "", // Add if you have a field for this
            fatherName: member.fatherName,
            cnic: member.cnic,
            email: member.email,
            phoneNumber: member.phoneNumber,
            alternatePhoneNumber: "",
            address: member.address,
            city:member.city,
            district:member.district?.title,
            village:member.village,
            dateOfBirth: formatToISO8601(dateString:member.dateOfBirth),
            gender: member.gender,
            maritalStatus:  member.maritalStatus,
            bloodGroup: "O+",
            education:  member.education,
            profession:  member.profession,
            skills:  member.skills,
            referralName:  member.referralName,
            designationId:  member.designationId,
            districtId:  member.districtId,
            constituencyId:  member.constituencyId,
            unionCouncilId:  member.unionCouncilId,
            wardId:  member.wardId,
            joiningDate: formatToISO8601(dateString:  member.joiningDate),
            membershipStatus: newStatus,
            notes: "",
            nameofLocalJamat: member.nameofLocalJamat,
            tempImageId: ""
        )

        self.activityIndicatorView.startAnimating()
        
        APIClient.shared.updateMember(id: member.id ?? 0, memberData: updatedData) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicatorView.stopAnimating()
                switch result {
                case .success:
                    if let index = self?.allMembers.firstIndex(where: { $0.id == member.id }) {
                            self?.allMembers[index].membershipStatus = newStatus
                            
                            // Reload ONLY this row with a nice animation
                            let indexPath = IndexPath(row: index, section: 0)
                            self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                        }
                case .failure(let error):
                    self?.handleAPIError(error)
                }
            }
        }    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // 1. Define the Edit Action
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] (action, view, completionHandler) in
            guard let self = self else { return }
            
            let member = self.allMembers[indexPath.row]
            
            // 2. Navigate to AddMemberViewController
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            if let editVC = storyBoard.instantiateViewController(withIdentifier: "AddMemberViewController") as? AddMemberViewController {
                
                // 3. Pass the member data to be edited
                editVC.memberToEdit = member
                
                editVC.modalPresentationStyle = .fullScreen
                editVC.modalTransitionStyle = .crossDissolve
                self.present(editVC, animated: true, completion: nil)
            }
            
            completionHandler(true) // Close the swipe action
        }
        
        // 4. Style the action
        editAction.backgroundColor = .systemBlue
        editAction.image = UIImage(systemName: "pencil") // Optional icon

        return UISwipeActionsConfiguration(actions: [editAction])
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        110
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let member = allMembers[indexPath.row]
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        if let detailVC = storyBoard.instantiateViewController(withIdentifier: "MemberDetailViewController") as? MemberDetailViewController {
            detailVC.memberData = member // Update your DetailVC to accept a 'Member' object
            detailVC.modalPresentationStyle = .fullScreen
            self.present(detailVC, animated: true)
        }
    }
}
