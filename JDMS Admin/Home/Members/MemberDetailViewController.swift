import UIKit
import SDWebImage

class MemberDetailViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var verifyView: UIView!
    @IBOutlet weak var verifylb: UILabel!
    @IBOutlet weak var Namelb: UILabel!
    
    // MARK: - Passed Data
    var memberData: Member?
    
    // MARK: - Sections Mapping
    let profileSections: [ProfileSection] = [
        ProfileSection(
            sectionTitle: "Personal Information / ذاتی معلومات",
            fields: [
                ProfileField(title: "Name", urduTitle: "نام", type: .text),
                ProfileField(title: "Father/Husband Name", urduTitle: "والد/شوہر کا نام", type: .text),
                ProfileField(title: "Email", urduTitle: "ای میل", type: .text),
                ProfileField(title: "CNIC", urduTitle: "شناختی کارڈ نمبر", type: .number),
                ProfileField(title: "Date of Birth", urduTitle: "تاریخ پیدائش", type: .date),
                ProfileField(title: "Gender", urduTitle: "جنس", type: .dropdown),
                ProfileField(title: "Membership Date", urduTitle: "رکنیت کی تاریخ", type: .date)
            ]
        ),
        ProfileSection(
            sectionTitle: "Location Information / جغرافیائی معلومات",
            fields: [
                ProfileField(title: "District", urduTitle: "ضلع", type: .text),
                ProfileField(title: "Constituency", urduTitle: "انتخابی حلقہ", type: .text),
                ProfileField(title: "Union Council", urduTitle: "یونین کونسل", type: .text),
                ProfileField(title: "Ward", urduTitle: "وارڈ", type: .text),
                ProfileField(title: "City", urduTitle: "شہر", type: .text),
                ProfileField(title: "Village", urduTitle: "گاؤں", type: .text),
                ProfileField(title: "Address", urduTitle: "پتہ", type: .text)
            ]
        ),
        ProfileSection(
            sectionTitle: "Career & Education / پیشہ و تعلیم",
            fields: [
                ProfileField(title: "Desigination", urduTitle: "عہدہ", type: .text),
                ProfileField(title: "Occupation", urduTitle: "پیشہ", type: .text),
                ProfileField(title: "Education", urduTitle: "تعلیم", type: .text),
                ProfileField(title: "Skills", urduTitle: "مہارت", type: .text)
            ]
        ),
        ProfileSection(
            sectionTitle: "Contact Details / رابطہ معلومات",
            fields: [
                ProfileField(title: "Home Phone", urduTitle: "گھر کا فون", type: .number),
                ProfileField(title: "Mobile", urduTitle: "موبائل", type: .number)
            ]
        )
    ]

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        roundCorneView(view: verifyView)
        tableView.delegate = self
        tableView.dataSource = self
        addDropShadow(to: bgView)
        tableView.tableFooterView = UIView()
        Namelb.text = memberData?.fullName
        
        let imagePath = memberData?.imageUrl ?? ""

        // 2. Only proceed if the path isn't empty
        if !imagePath.isEmpty {
            let finalUrlString = APIClient.shared.baseURL + imagePath
            
            if let url = URL(string: finalUrlString) {
                profileImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "user"))
            }
        } else {
            // 3. If no path exists, explicitly set the placeholder
            profileImageView.image = UIImage(named: "user")
        }
        
        verifylb.text = memberData?.membershipStatus
        
        if memberData?.membershipStatus == "VERIFIED"
        {
            verifyView.backgroundColor = .green
        }
        else
        {
            verifyView.backgroundColor = .red
        }
        
       
        
    }
    
    // This helper function maps the static Title to the Member object property
    func getValueForField(_ title: String) -> String {
        guard let member = memberData else { return "-" }
        
        switch title {
        case "Name": return member.fullName
        case "Father/Husband Name": return member.fatherName
        case "Email": return member.email ?? "-"
        case "CNIC": return member.cnic
        case "Date of Birth": return member.dateOfBirth?.split(separator: "T").first.map(String.init) ?? "-"
        case "Gender": return member.gender ?? ""
        case "Membership Date": return member.joiningDate?.split(separator: "T").first.map(String.init) ?? "-"
        case "District": return member.district?.name ?? "-"
        case "Constituency": return member.constituency?.name ?? "-"
        case "Union Council": return member.unionCouncil?.name ?? "-"
        case "Ward": return member.ward?.name ?? "-"
        case "City": return member.city
        case "Village": return member.village ?? "-"
        case "Address": return member.address ?? "-"
        case "Desigination": return member.designation?.title ?? "-" // Check your 'Member' property name for designation
        case "Occupation": return member.profession ?? "-"
        case "Education": return member.education
        case "Skills": return member.skills ?? "-"
        case "Home Phone": return member.alternatePhoneNumber ?? "-"
        case "Mobile": return member.phoneNumber
        default: return "-"
        }
    }
    
    
    private func performDelete(id: Int) {
        // 2. Show Loader (assuming you have your activityIndicator setup)
        // startLoading(view: self.activityIndicatorView)
        
        APIClient.shared.deleteMember(id: id) { [weak self] result in
            // self?.stopLoading(view: self?.activityIndicatorView)
            
            switch result {
            case .success:
                // 3. Inform user and go back
                self?.showAlertWithButtons(title: "Success", message: "Member deleted successfully.", okTitle: "OK", cancelTitle: nil) {
                    // Return to the list view
                    self?.dismiss(animated: true)
                    
                    // Optional: Post a notification to refresh the list in MembersViewController
                    NotificationCenter.default.post(name: NSNotification.Name("MemberDeleted"), object: nil)
                }
                
            case .failure(let error):
                self?.handleAPIError(error)
            }
        }
    }

    
    @IBAction func backBtnTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func deleteBtnTapped(_ sender: UIButton) {
        guard let memberId = memberData?.id else {
            self.showAlertWithButtons(title: "Error", message: "Invalid Member ID", cancelTitle: nil)
            return
        }
        
        // 1. Show Confirmation Alert
        self.showAlertWithButtons(title: "Delete Member",
                       message: "Are you sure you want to permanently delete \(memberData?.fullName ?? "this member")?",
                       okTitle: "Delete",
                       cancelTitle: "Cancel") { [weak self] in
            
            self?.performDelete(id: memberId)
        }
    }

    
}

// MARK: - TableView Extensions
extension MemberDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return profileSections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profileSections[section].fields.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DetailMemberTableViewCell
        
        // Get the field definition from our static array
        let field = profileSections[indexPath.section].fields[indexPath.row]
        
        cell.titleLb.font = .jameelNastaleeq(14)
        cell.valueLb.font = .jameelNastaleeq(16)
        
        // Set the Labels
        cell.titleLb.text = "\(field.title) / \(field.urduTitle)"
        cell.valueLb.text = getValueForField(field.title)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.systemGroupedBackground
        
        let label = UILabel()
        label.text = profileSections[section].sectionTitle
        label.font = .boldSystemFont(ofSize: 14)
        label.textColor = .darkGray
        label.frame = CGRect(x: 15, y: 5, width: tableView.frame.width - 30, height: 30)
        
        headerView.addSubview(label)
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
}
