//
//  ConstituencyDetailViewController.swift
//  JDMS Admin
//
//  Created by Moin Janjua on 10/03/2026.
//

import UIKit
import NVActivityIndicatorView

class ConstituencyDetailViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var constituencyTextField: UITextField! // Use this as the "Dropdown"
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    @IBOutlet weak var nodatImage: UIImageView!
    
    var districtId: Int?
    var constituencies: [Constituency1] = []
    var selectedConstituency: Constituency1?
    
    var unionCouncils: [UnionCouncil1] = []
    private var wardsByUC: [Int: [Ward1]] = [:]
    private var expandedUCIds: Set<Int> = []
    
    let picker = UIPickerView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDropdown()
        fetchConstituencies()
    }

    func setupUI() {
        nodatImage.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        activityIndicator.type = .ballClipRotateMultiple
    }

    func setupDropdown() {
        picker.delegate = self
        picker.dataSource = self
        constituencyTextField.inputView = picker
        constituencyTextField.placeholder = "Select Constituency"
        
        // --- ADD THE TOOLBAR HERE ---
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneBtn = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(donePicker))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexSpace, doneBtn], animated: true)
        constituencyTextField.inputAccessoryView = toolbar
        // ----------------------------

        let arrowContainer = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        let arrow = UIImageView(image: UIImage(systemName: "chevron.down"))
        arrow.frame = CGRect(x: 0, y: 5, width: 15, height: 15)
        arrow.tintColor = .systemGray
        arrow.contentMode = .scaleAspectFit
        arrowContainer.addSubview(arrow)
        
        constituencyTextField.rightView = arrowContainer
        constituencyTextField.rightViewMode = .always
        constituencyTextField.layer.borderWidth = 1
        constituencyTextField.layer.borderColor = UIColor.systemGray5.cgColor
        constituencyTextField.layer.cornerRadius = 8
    }



    @objc func donePicker() {
        constituencyTextField.resignFirstResponder()
        if let selected = selectedConstituency {
            fetchUnionCouncils(for: selected.id)
        }
    }
    
    @IBAction func backBtn(_ sender: UIButton) {
        
        self.dismiss(animated: true)
    }

    // Inside ConstituencyDetailViewController...

    func fetchConstituencies() {
        guard let dId = districtId else { return }
        self.activityIndicator.startAnimating()
        
        APIClient.shared.getConstituencyByDistrict(id: dId) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                switch result {
                case .success(let constituency):
                    // Wrap the single object in an array so your Table/Picker still works
                    self?.constituencies = [constituency]
                    
                    self?.constituencyTextField.text = constituency.name
                    self?.selectedConstituency = constituency
                    
                    // Fetch the next level
                    self?.fetchUnionCouncils(for: constituency.id)
                    
                    self?.picker.reloadAllComponents()
                    self?.updateNoDataState()
                    
                case .failure(let error):
                    print("Decoding Error: \(error)")
                    self?.showAlert(title: "Error", message: "Could not parse constituency data.")
                }
            }
        }
    }

    func fetchUnionCouncils(for id: Int) {
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }
        APIClient.shared.getUCByConstituency(id: id) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                switch result {
                case .success(let uc):
                    // Wrap the single 'uc' object in brackets to make it an array
                    self?.unionCouncils = [uc]
                    
                    self?.expandedUCIds.removeAll()
                    self?.tableView.reloadData()
                    self?.updateNoDataState()
                    
                case .failure(let error):
                    print("UC Fetch Error: \(error)")
                    self?.showAlert(title: "Error", message: "Could not load Union Council data.")
                }
            }
        }
    }

    // Fetch Wards (Call this when a UC section is tapped)
    func fetchWards(for ucId: Int, in section: Int) {
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }
        
        // Changing the call to match your updated APIClient method
        APIClient.shared.getWardByUC(id: ucId) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                switch result {
                case .success(let ward): // 'ward' is now a single object
                    // 1. Wrap the single ward in an array [ward] so the TableView can loop through it
                    self?.wardsByUC[ucId] = [ward]
                    
                    // 2. Mark as expanded
                    self?.expandedUCIds.insert(ucId)
                    
                    // 3. Refresh just that section to show the new rows
                    self?.tableView.reloadSections(IndexSet(integer: section), with: .fade)
                    
                case .failure(let error):
                    self?.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    
    
    func updateNoDataState() {
        let hasNoData = constituencies.isEmpty
        nodatImage.isHidden = !hasNoData
        tableView.isHidden = hasNoData
    }
    
}

// MARK: - PickerView (Dropdown) Logic
extension ConstituencyDetailViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return constituencies.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return constituencies[row].name
    }
    // Update this to trigger data fetch immediately
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selected = constituencies[row]
        selectedConstituency = selected
        constituencyTextField.text = selected.name // Visual feedback while scrolling
    }
}

// MARK: - TableView (UC & Wards) Logic
extension ConstituencyDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return unionCouncils.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let uc = unionCouncils[section]
        return expandedUCIds.contains(uc.id) ? (wardsByUC[uc.id]?.count ?? 0) : 0
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let uc = unionCouncils[section]
        let isExpanded = expandedUCIds.contains(uc.id)
        
        // Re-use your professional card style from the Regions screen
        let container = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 52))
        let card = UIView(frame: CGRect(x: 10, y: 2, width: tableView.frame.width - 20, height: 48))
        card.backgroundColor = .systemBackground
        card.layer.cornerRadius = 8
        card.tag = section
        
        let label = UILabel(frame: CGRect(x: 15, y: 0, width: 200, height: 48))
        label.text = "UC: \(uc.name)"
        label.font = .systemFont(ofSize: 15, weight: .bold)
        
        let arrow = UIImageView(frame: CGRect(x: card.frame.width - 30, y: 16, width: 16, height: 16))
        arrow.image = UIImage(systemName: isExpanded ? "chevron.up" : "chevron.down")
        arrow.tintColor = .systemGreen
        
        card.addSubview(label)
        card.addSubview(arrow)
        container.addSubview(card)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleUCTap(_:)))
        card.addGestureRecognizer(tap)
        
        return container
    }

    @objc func handleUCTap(_ gesture: UITapGestureRecognizer) {
        guard let section = gesture.view?.tag else { return }
        let ucId = unionCouncils[section].id
        
        if expandedUCIds.contains(ucId) {
            expandedUCIds.remove(ucId)
            tableView.reloadSections(IndexSet(integer: section), with: .automatic)
        } else {
            fetchWards(for: ucId, in: section)
           
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 52
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! regionsTableViewCell
        let ucId = unionCouncils[indexPath.section].id
        
        if let wards = wardsByUC[ucId] {
            let ward = wards[indexPath.row]
            // Use an icon and extra leading spaces for a "nested" look
            cell.districtlb?.text = "    ↳  Ward \(ward.name)"
            cell.districtlb?.textColor = .secondaryLabel
        }
        return cell
    }
}
