//
//  AddMemberViewController.swift
//  JDMS Admin
//
//  Created by Moin Janjua on 02/01/2026.
//

import UIKit
import NVActivityIndicatorView

class AddMemberViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate ,UITextFieldDelegate{
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var personalView: UIView!
    @IBOutlet weak var addressView: UIView!
    @IBOutlet weak var contactView: UIView!
    @IBOutlet weak var memeberImg: UIImageView!
    
    // Personal Info (Assuming these are actually TextFields or similar for input)
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var fatNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var cnicTextField: UITextField!
    @IBOutlet weak var dobTextField: UITextField!
    @IBOutlet weak var genderDropDown: DropDown!
    @IBOutlet weak var martialStatusDropDown: DropDown!
    
    // Address Info
    @IBOutlet weak var districtDropDown: DropDown!
    @IBOutlet weak var constitutionDropDown: DropDown!
    @IBOutlet weak var ucDropDown: DropDown!
    @IBOutlet weak var wardDropDown: DropDown!
    @IBOutlet weak var memberStatus: DropDown!
    
    // Academic Info
    @IBOutlet weak var occupationDropDown: DropDown!
    @IBOutlet weak var educationDropDown: DropDown!
    @IBOutlet weak var skillsTextView: UITextView!
    
    @IBOutlet weak var designationDropDown: DropDown!
    @IBOutlet weak var VillageLb: UITextField!
    @IBOutlet weak var Citylb: UITextField!
    @IBOutlet weak var permenantAddress: UITextField!
    @IBOutlet weak var localAddress: UITextField!
    @IBOutlet weak var nameofLocaljamat: UITextField!
    @IBOutlet weak var joiningDate: UITextField!
    @IBOutlet weak var phoneLb: UITextField!
    @IBOutlet weak var HomePhonelb: UITextField!
    @IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!
    @IBOutlet weak var referenceTF: UITextField!
    
    // Data Storage
    var districts: [District] = []
    var constituencies: [Constituency2] = []
    var unionCouncils: [UnionCouncil2] = []
    var wards: [Ward2] = []
    var designations: [Designation] = []
    var selectedDesignationId: Int?
    // Selected IDs for Final Save
    var selectedDistrictId: Int?
    var selectedConstituencyId: Int?
    var selectedUCId: Int?
    var selectedWardId: Int?
    
    var memberToEdit: Member?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupStaticDropDowns()
        setupDynamicDropDownSelection()
        setupDatePickers() // Add this here
        loadDesignations()
        loadDistricts()
        
        if memberToEdit != nil {
                preFillMemberData()
            }
    }
    
    
    func preFillMemberData() {
        guard let member = memberToEdit else { return }
        
        // Personal Info
        nameTextField.text = member.fullName
        fatNameTextField.text = member.fatherName
        cnicTextField.text = member.cnic
        emailTextField.text = member.email
        dobTextField.text = String(member.dateOfBirth?.prefix(10) ?? "") // Take only YYYY-MM-DD
        genderDropDown.text = member.gender
        martialStatusDropDown.text = member.maritalStatus
        
        // Address & IDs
        Citylb.text = member.city
        VillageLb.text = member.village
        permenantAddress.text = member.address // If your model has this
        localAddress.text = member.address
        districtDropDown.text = member.district?.name
        selectedDistrictId = member.districtId
        selectedConstituencyId = member.constituencyId
        constitutionDropDown.text = member.constituency?.name
        ucDropDown.text = member.constituency?.name
        wardDropDown.text = member.ward?.name
        selectedUCId = member.unionCouncilId
        selectedWardId = member.wardId
        designationDropDown.text = member.designation?.title ?? member.designation?.name
        selectedDesignationId = member.designationId        // Academic & Jamat
        educationDropDown.text = member.education
        occupationDropDown.text = member.profession
        skillsTextView.text = member.skills
        phoneLb.text = member.phoneNumber
        HomePhonelb.text = member.alternatePhoneNumber
        nameofLocaljamat.text = member.nameofLocalJamat
        joiningDate.text = String(member.joiningDate?.prefix(10) ?? "")
        referenceTF.text = member.referralName
        
        // Profile Image
        if let imagePath = member.imageUrl, !imagePath.isEmpty {
            let finalUrlString = APIClient.shared.baseURL + imagePath
            if let url = URL(string: finalUrlString) {
                memeberImg.sd_setImage(with: url, placeholderImage: UIImage(named: "user"))
            }
        }
    }
    
    
    func setupDatePickers() {
        // Create DatePickers for both fields
        createDatePicker(for: dobTextField, selector: #selector(dobDateChanged))
        createDatePicker(for: joiningDate, selector: #selector(joiningDateChanged))
    }
    
    
    func createDatePicker(for textField: UITextField, selector: Selector) {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        
        // Use .wheels for the old-style scroll or .inline/.compact for newer iOS styles
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        
        textField.inputView = datePicker
        
        // Add a Toolbar with a "Done" button
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexibleSpace, doneButton], animated: true)
        textField.inputAccessoryView = toolbar
        
        // Add target to detect value changes
        datePicker.addTarget(self, action: selector, for: .valueChanged)
    }

    @objc func donePressed() {
        view.endEditing(true) // Hides the date picker
    }

    @objc func dobDateChanged(_ sender: UIDatePicker) {
        dobTextField.text = formatDate(date: sender.date)
    }

    @objc func joiningDateChanged(_ sender: UIDatePicker) {
        joiningDate.text = formatDate(date: sender.date)
    }

    func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd" // Visual format for the user
        return formatter.string(from: date)
    }

    // Helper for the API's ISO 8601 requirement
    
    func setupUI() {
        cnicTextField.delegate = self
        cnicTextField.keyboardType = .numberPad
        [bgView, personalView, addressView, contactView].forEach { addDropShadow(to: $0) }
        memeberImg.layer.cornerRadius = memeberImg.frame.height / 2
        skillsTextView.layer.borderWidth = 1
        skillsTextView.layer.borderColor = UIColor.systemGray4.cgColor
        
        memeberImg.contentMode = .scaleAspectFill // This ensures the image fills the circle
        memeberImg.clipsToBounds = true           // This cuts off the image outside the circle
        memeberImg.layer.cornerRadius = memeberImg.frame.height / 2
    }
    
    // MARK: - Static Data
    func setupStaticDropDowns()
    {
        memberStatus.text = "NON_VERIFIED"
        genderDropDown.optionArray = ["Male", "Female", "Other"]
        martialStatusDropDown.optionArray = ["Single", "Married", "Widowed", "Divorced"]
        memberStatus.optionArray = ["NON_VERIFIED","VERIFIED"]
        districtDropDown.didSelect { [weak self] (selectedText, index, id) in
            self?.memberStatus.text = selectedText
            
        }
        occupationDropDown.optionArray = ["Business", "Private Job", "Government Job", "Student", "Labor", "Other"]
        educationDropDown.optionArray = ["Matric", "Intermediate", "Bachelors", "Masters", "PhD", "Primary","Secondary"]
    }
    
    // MARK: - Dynamic Selection Logic
    func setupDynamicDropDownSelection() {
        // 1. When District Selected -> Load Constituencies
        districtDropDown.didSelect { [weak self] (selectedText, index, id) in
            let districtId = self?.districts[index].id
            self?.selectedDistrictId = districtId
            self?.constitutionDropDown.text = "" // Reset children
            self?.loadConstituencies(districtId: districtId)
        }
        
        // 2. When Constituency Selected -> Load UC
        constitutionDropDown.didSelect { [weak self] (selectedText, index, id) in
            let constituencyId = self?.constituencies[index].id
            self?.selectedConstituencyId = constituencyId
            self?.ucDropDown.text = ""
            self?.getUnionCouncil(id: constituencyId ?? 0)
        }
        
        // 3. When UC Selected -> Load Ward
        ucDropDown.didSelect { [weak self] (selectedText, index, id) in
            let ucId = self?.unionCouncils[index].id
            self?.selectedUCId = ucId
            self?.wardDropDown.text = ""
            self?.getWards(id: ucId ?? 0)
        }
        
        // 4. When Ward Selected
        wardDropDown.didSelect { [weak self] (selectedText, index, id) in
            self?.selectedWardId = self?.wards[index].id
        }
    }
    
    
    // MARK: - API Calls
    func loadDistricts() {
        APIClient.shared.getAllDistricts { [weak self] result in
            if case .success(let fetched) = result {
                self?.districts = fetched
                self?.districtDropDown.optionArray = fetched.map { $0.name }
            }
        }
    }
    
    func loadConstituencies(districtId: Int?) {
        APIClient.shared.getConstituencies(districtId: districtId) { [weak self] result in
            if case .success(let list) = result {
                self?.constituencies = list
                self?.constitutionDropDown.optionArray = list.map { $0.name }
            }
        }
    }
    
    func getUnionCouncil(id: Int) {
        APIClient.shared.getUnionCouncils(constituencyId: id) { [weak self] result in
            if case .success(let data) = result {
                self?.unionCouncils = data
                self?.ucDropDown.optionArray = data.map { $0.name }
            }
        }
    }
    
    func getWards(id: Int) {
        APIClient.shared.getWards(unionCouncilId: id) { [weak self] result in
            if case .success(let data) = result {
                self?.wards = data
                self?.wardDropDown.optionArray = data.map { $0.name }
            }
        }
    }
    
    func loadDesignations() {
        APIClient.shared.getDesignations { [weak self] result in
            if case .success(let list) = result {
                self?.designations = list
                self?.designationDropDown.optionArray = list.map { $0.title }
                
                // Handle Selection
                self?.designationDropDown.didSelect { (selectedText, index, id) in
                    
                    self?.designationDropDown.text = selectedText
                    self?.selectedDesignationId = self?.designations[index].id
                }
            }
        }
    }
    
    @IBAction func AddImageBtnTapped(_ sender: UIButton) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary // or .camera
            picker.allowsEditing = true
            present(picker, animated: true)
        }
        
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            memeberImg.image = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            memeberImg.image = originalImage
        }
        dismiss(animated: true)
    }
    
    
    @IBAction func backBtnTapped(_ sender: UIButton) {
        
        self.dismiss(animated: true)
    }
    
    @IBAction func SaveBtnTapped(_ sender: UIButton) {
        guard validateFields() else { return }
        
        startLoading(view: self.activityIndicatorView)
        
        // If we have an image, upload it first to get tempImageId
        if let image = self.memeberImg.image, image != UIImage(named: "user") {
            APIClient.shared.uploadMemberImage(image: image) { [weak self] result in
                switch result {
                case .success(let tempId):
                    self?.handleFinalSubmission(tempImageId: tempId)
                case .failure(let error):
                    self?.activityIndicatorView.stopAnimating()
                    self?.handleAPIError(error)
                }
            }
        } else {
            handleFinalSubmission(tempImageId: "")
        }
    }

    func handleFinalSubmission(tempImageId: String) {
        if let member = memberToEdit {
            // CALL UPDATE API
            updateExistingMember(id: member.id ?? 0, tempImageId: tempImageId)
        } else {
            // CALL SAVE API
            sendFinalMemberData(tempImageId: tempImageId)
        }
    }
    
    func validateFields() -> Bool {
        // 1. Personal Info
        if nameTextField.text?.isEmpty ?? true {
            showAlert(title: "Missing Info", message: "Please enter Full Name"); return false
        }
        if fatNameTextField.text?.isEmpty ?? true {
            showAlert(title: "Missing Info", message: "Please enter Father Name"); return false
        }
        if cnicTextField.text?.isEmpty ?? true {
            showAlert(title: "Missing Info", message: "Please enter CNIC Number"); return false
        }
        if dobTextField.text?.isEmpty ?? true {
            showAlert(title: "Missing Info", message: "Please select Date of Birth"); return false
        }
        if genderDropDown.text?.isEmpty ?? true {
            showAlert(title: "Missing Info", message: "Please select Gender"); return false
        }

        // 2. Address Info (Hierarchy)
        if districtDropDown.text?.isEmpty ?? true {
            showAlert(title: "Missing Info", message: "Please select District"); return false
        }
        if constitutionDropDown.text?.isEmpty ?? true {
            showAlert(title: "Missing Info", message: "Please select Constituency"); return false
        }
        if ucDropDown.text?.isEmpty ?? true {
            showAlert(title: "Missing Info", message: "Please select Union Council"); return false
        }
        if wardDropDown.text?.isEmpty ?? true {
            showAlert(title: "Missing Info", message: "Please select Ward"); return false
        }
        if Citylb.text?.isEmpty ?? true {
            showAlert(title: "Missing Info", message: "Please enter City"); return false
        }
        if VillageLb.text?.isEmpty ?? true {
            showAlert(title: "Missing Info", message: "Please enter Village"); return false
        }

        // 3. Academic & Contact
        if occupationDropDown.text?.isEmpty ?? true {
            showAlert(title: "Missing Info", message: "Please select Occupation"); return false
        }
        if educationDropDown.text?.isEmpty ?? true {
            showAlert(title: "Missing Info", message: "Please select Education"); return false
        }
        if phoneLb.text?.isEmpty ?? true {
            showAlert(title: "Missing Info", message: "Please enter Phone Number"); return false
        }

        return true // All checks passed
    }
    
    func sendFinalMemberData(tempImageId: String) {
        // 3. Construct the full request object
        let memberData = MemberRequest(
            fullname: nameTextField.text ?? "",
            urduName: "", // Add field if needed
            fatherName: fatNameTextField.text ?? "",
            cnic: cnicTextField.text ?? "",
            email: emailTextField.text,
            tempImageId: tempImageId,
            phoneNumber: phoneLb.text ?? "",
            alternatePhoneNumber: HomePhonelb.text,
            address: localAddress.text ?? "",
            city: Citylb.text ?? "",
            district: districtDropDown.text ?? "",
            village: VillageLb.text,
            dateOfBirth: formatToISO8601(dateString: dobTextField.text),
            gender: genderDropDown.text ?? "",
            maritalStatus: martialStatusDropDown.text ?? "",
            bloodGroup: "O+",
            education: educationDropDown.text ?? "",
            profession: occupationDropDown.text ?? "",
            skills: skillsTextView.text,
            referralName: referenceTF.text,
            designationId: selectedDesignationId ?? 1,
            districtId: selectedDistrictId ?? 0,
            constituencyId: selectedConstituencyId ?? 0,
            unionCouncilId: selectedUCId ?? 0,
            wardId: selectedWardId ?? 0,
            membershipStatus: self.memberStatus.text ?? "NON_VERIFIED",
            joiningDate: formatToISO8601(dateString: joiningDate.text),
            notes: "",
            nameofLocalJamat: nameofLocaljamat.text
        )
        
        // 4. Step 2: Call the Save API
        APIClient.shared.saveMember(params: memberData) { [weak self] result in
            self?.activityIndicatorView.stopAnimating()
            
            switch result {
            case .success(let message):
                // Show Success Title
                self?.showAlert(title: "Success", message: message)
                
            case .failure(let error):
                // Show Error Title
                self?.handleAPIError(error)
            }
        }
    }
    
    
    func updateExistingMember(id: Int, tempImageId: String) {
        // Construct the Update Request
        let updatedData = MemberUpdateRequest(
            id: id,
            fullName: nameTextField.text,
            urduName: "", // Add if you have a field for this
            fatherName: fatNameTextField.text,
            cnic: cnicTextField.text,
            email: emailTextField.text,
            phoneNumber: phoneLb.text,
            alternatePhoneNumber: HomePhonelb.text,
            address: localAddress.text,
            city: Citylb.text,
            district: districtDropDown.text,
            village: VillageLb.text,
            dateOfBirth: formatToISO8601(dateString: dobTextField.text),
            gender: genderDropDown.text,
            maritalStatus: martialStatusDropDown.text,
            bloodGroup: "O+",
            education: educationDropDown.text,
            profession: occupationDropDown.text,
            skills: skillsTextView.text,
            referralName: referenceTF.text,
            designationId: selectedDesignationId ?? 1,
            districtId: selectedDistrictId ?? 0,
            constituencyId: selectedConstituencyId ?? 0,
            unionCouncilId: selectedUCId ?? 0,
            wardId: selectedWardId ?? 0,
            joiningDate: formatToISO8601(dateString: joiningDate.text),
            membershipStatus: memberStatus.text ?? "NON_VERIFIED",
            notes: "",
            nameofLocalJamat: nameofLocaljamat.text,
            tempImageId: tempImageId
        )

        APIClient.shared.updateMember(id: id, memberData: updatedData) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicatorView.stopAnimating()
                switch result {
                case .success:
                    self?.showAlertWithButtons(title: "Success", message: "Member updated successfully") {
                        self?.dismiss(animated: true)
                    }
                case .failure(let error):
                    self?.handleAPIError(error)
                }
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == cnicTextField {
            let currentString = (textField.text ?? "") as NSString
            let newString = currentString.replacingCharacters(in: range, with: string)
            return newString.count <= 13
        }
        return true
    }
    
}

func formatToISO8601(dateString: String?) -> String {
    guard let dateString = dateString, !dateString.isEmpty else {
        return "2026-02-19T00:00:00.000Z" // Fallback
    }
    
    let displayFormatter = DateFormatter()
    displayFormatter.dateFormat = "yyyy-MM-dd"
    
    if let date = displayFormatter.date(from: dateString) {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return isoFormatter.string(from: date)
    }
    return "2026-02-19T00:00:00.000Z"
}
