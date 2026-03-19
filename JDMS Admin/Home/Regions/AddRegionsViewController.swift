//
//  RegionsViewController.swift
//  JDMS Admin
//
//  Created by Moin Janjua on 29/12/2025.
//

import UIKit
import NVActivityIndicatorView

class AddRegionsViewController: UIViewController {

    @IBOutlet weak var View1: UIView!; @IBOutlet weak var View2: UIView!
    @IBOutlet weak var View3: UIView!; @IBOutlet weak var View4: UIView!
    
    @IBOutlet weak var regionTF: UITextField!
    @IBOutlet weak var DistrictTF: UITextField!
    @IBOutlet weak var constituencyTF: UITextField!
    @IBOutlet weak var unionCouncilTF: UITextField!
    @IBOutlet weak var wardTF: UITextField!
    
    @IBOutlet weak var regionDD: DropDown!
    @IBOutlet weak var DistrictDD: DropDown!
    @IBOutlet weak var constituencyDD: DropDown!
    @IBOutlet weak var uniobCoubncilDD: DropDown!
    
    @IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!

    
    // Data storage using your JDModels
    var regions: [JDRegion] = []
    var districts: [District] = []
    var constituencies: [Constituency1] = []
    var unionCouncils: [UnionCouncil2] = []
    
    var selectedRegionId: Int?
    var selectedDistrictId: Int?
    var selectedConstituencyId: Int?
    var selectedUCId: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicatorView.type = .ballPulse
        activityIndicatorView.color = .systemGreen
        setupUI()
        setupDropDownClosures()
        loadAllRegions()
        loadDistricts()
        fetchAllConstituencies()
        loadUnionCouncils()
    }

    func setupUI() {
        [View1, View2, View3, View4].forEach { addDropShadow(to: $0!) }
        
        // Configure JRDropDown properties
        [regionDD, DistrictDD, constituencyDD, uniobCoubncilDD].forEach {
            $0?.isSearchEnable = true
            $0?.rowHeight = 40
          
        }
    }
    
    // MARK: - DropDown Selection Logic
    func setupDropDownClosures() {
        
        // 1. When Region is selected -> Fetch Districts for that Region
        regionDD.didSelect { [weak self] (name, index, id) in
            self?.selectedRegionId = id
            self?.regionTF.text = name
        }
        
        // 2. When District is selected -> Fetch Constituencies
        DistrictDD.didSelect { [weak self] (name, index, id) in
            self?.selectedDistrictId = id
            self?.DistrictTF.text = name
        }
        
        // 3. When Constituency is selected -> Fetch UCs
        constituencyDD.didSelect { [weak self] (name, index, id) in
            self?.selectedConstituencyId = id
            self?.constituencyTF.text = name
        }
        
        // 4. When UC is selected -> Ready for Ward saving
        uniobCoubncilDD.didSelect { [weak self] (name, index, id) in
            self?.selectedUCId = id
            self?.unionCouncilTF.text = name
        }
    }

    // MARK: - API Loading Methods
    
    func loadAllRegions() {
        DispatchQueue.main.async {
            self.activityIndicatorView.startAnimating()
        }
        APIClient.shared.getAllRegions { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicatorView.stopAnimating()
                if case .success(let data) = result {
                    self?.regions = data
                    self?.regionDD.optionArray = data.map { $0.name }
                    self?.regionDD.optionIds = data.map { $0.id }
                }
            }
        }
    }
    

    func loadDistricts()
    {
        APIClient.shared.getAllDistricts { [weak self] result in
            if case .success(let fetched) = result {
                self?.districts = fetched
                self?.DistrictDD.optionArray = fetched.map { $0.name }
                self?.DistrictDD.optionIds = fetched.map { $0.regionId }
                self?.DistrictDD.text = ""
            }
        }
    }
    
    func fetchAllConstituencies() {
        // Optional: Start loading indicator here
        APIClient.shared.getAllConstituencies { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    // 1. Store the full objects
                    self?.constituencies = data
                    
                    // 2. Map names to the dropdown's display array
                    self?.constituencyDD.optionArray = data.map { $0.name }
                    
                    // 3. Map IDs to the dropdown's ID array
                    self?.constituencyDD.optionIds = data.map { $0.id }
                    
                    // 4. Reset the text to prompt selection
                    self?.constituencyDD.text = ""
                    
                case .failure(let error):
                    print("Error fetching all constituencies: \(error)")
                    self?.showAlert(title: "Error", message: "Failed to load constituencies.")
                }
            }
        }
    }

    
    func loadUnionCouncils() {
        // Optional: Start your activity indicator here
        
        APIClient.shared.getUnionCouncils(constituencyId: 0) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedUCs):
                    // 1. Store the raw data in your array
                    self?.unionCouncils = fetchedUCs
                    
                    // 2. Map names to the dropdown array
                    self?.uniobCoubncilDD.optionArray = fetchedUCs.map { $0.name }
                    
                    // 3. Map the IDs so you can use them later (for Wards)
                    self?.uniobCoubncilDD.optionIds = fetchedUCs.map { $0.id }
                    
                    // 4. Clear the current text so the user sees the new options
                    self?.uniobCoubncilDD.text = ""
                    
                case .failure(let error):
                    print("❌ Failed to load UCs: \(error.localizedDescription)")
                    self?.showAlert(title: "Error", message: "Could not load Union Councils.")
                }
            }
        }
    }

    // MARK: - Save Actions
    
    @IBAction func regionSavebtnTapped(_ sender: UIButton) {
        guard let name = regionTF.text, !name.isEmpty else { return }
        DispatchQueue.main.async {
            self.activityIndicatorView.startAnimating()
        }
        APIClient.shared.saveRegion(name: name, urdu: "", code: "", desc: "") { [weak self] result in
            self?.handleResponse(result: result, message: "Region Saved")
        }
    }

    @IBAction func districtSavebtnTapped(_ sender: UIButton) {
        // 1. Validate inputs
        guard let name = DistrictTF.text, !name.isEmpty,
              let rId = selectedRegionId else {
            showAlert(title: "Error", message: "Please enter name and select region")
            return
        }
        
        // 2. Call the API
        DispatchQueue.main.async {
            self.activityIndicatorView.startAnimating()
        }
        APIClient.shared.saveDistrictBtRegionID(name: name, regionId: rId, urdu: "", code: "", desc: "") { [weak self] result in
            // 3. Use your existing handleResponse helper
            self?.handleResponse(result: result, message: "District Saved")
            
            // 4. Optional: Close the screen on success
            if case .success = result {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self?.dismiss(animated: true)
                }
            }
        }
    }

    @IBAction func constituteSavebtnTapped(_ sender: UIButton) {
        guard let name = constituencyTF.text, let dId = selectedDistrictId else { return }
        DispatchQueue.main.async {
            self.activityIndicatorView.startAnimating()
        }
        
        APIClient.shared.saveConstituency(name: name, districtId: dId, urdu: "", code: "", desc: "") { [weak self] result in
            self?.handleResponse(result: result, message: "Constituency Saved")
        }
    }

    @IBAction func unionCouncilnSavebtnTapped(_ sender: UIButton) {
        guard let name = unionCouncilTF.text, let cId = selectedConstituencyId else { return }
        
        DispatchQueue.main.async {
            self.activityIndicatorView.startAnimating()
        }
        
        APIClient.shared.saveUC(name: name, constituencyId: cId, urdu: "", code: "", desc: "") { [weak self] result in
            self?.handleResponse(result: result, message: "UC Saved")
        }
    }

    @IBAction func wardSavebtnTapped(_ sender: UIButton) {
        guard let name = wardTF.text, let ucId = selectedUCId else { return }
        
        DispatchQueue.main.async {
            self.activityIndicatorView.startAnimating()
        }
        
        APIClient.shared.saveWard(name: name, ucId: ucId, urdu: "", code: "", desc: "") { [weak self] result in
            self?.handleResponse(result: result, message: "Ward Saved")
        }
    }

    // MARK: - Helpers
    
   

    private func handleResponse<T>(result: Result<T, Error>, message: String) {
        DispatchQueue.main.async {
            self.activityIndicatorView.stopAnimating()
            switch result {
            case .success:
                self.showAlert(title: "Success", message: message)
            case .failure(let error):
                self.showAlert(title: "Error", message: error.localizedDescription)
            }
        }
    }

    @IBAction func backbtnTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
