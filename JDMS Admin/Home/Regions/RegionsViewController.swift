//
//  RegionsViewController.swift
//  JDMS Admin
//
//  Created by Moin Janjua on 04/01/2026.
//

import UIKit
import SideMenu

class RegionsViewController: UIViewController {
    
    @IBOutlet weak var addbtn: UIButton!
    @IBOutlet weak var districtDD: DropDown!
    @IBOutlet weak var uCouncilDD: DropDown!
    @IBOutlet weak var regionDD: DropDown!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var detailsView: UIView!
    
    @IBOutlet weak var regionLb: UILabel!
    @IBOutlet weak var districtLb: UILabel!
    @IBOutlet weak var constintuteLb: UILabel!
    @IBOutlet weak var unionCLb: UILabel!
    @IBOutlet weak var wardLb: UILabel!
    
    private let allAffiliations = dummyAffiliations
    private var affiliations: [Affiliation] = []
    
    private var selectedAffiliation: Affiliation?
    private var selectedConstituency: Constituency?
    private var selectedUC: UnionCouncil?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        roundCorner(button: addbtn)
        addDropShadow(to: addbtn)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        searchbar.delegate = self
        shadowView.isHidden = true
        affiliations = allAffiliations
        tableView.reloadData()
        addDropShadow(to: detailsView)
        setupDistrictDropdown()
    }
    
    
    
    func applyFilters() {
        
        affiliations = allAffiliations.filter { affiliation in
            
            if let selectedAffiliation,
               affiliation.id != selectedAffiliation.id {
                return false
            }
            
            if let selectedConstituency {
                return affiliation.constituencies.contains {
                    $0.id == selectedConstituency.id
                }
            }
            
            if let selectedUC {
                return affiliation.constituencies
                    .flatMap { $0.unionCouncils }
                    .contains { $0.id == selectedUC.id }
            }
            
            return true
        }
        
        tableView.reloadData()
    }
    
    
    
    func setupDistrictDropdown() {
        
        districtDD.optionArray = allAffiliations.map { $0.name }
        
        districtDD.didSelect { [weak self] selectedText, index, id in
            guard let self = self else { return }
            
            self.selectedAffiliation = self.allAffiliations[index]
            
            self.selectedConstituency = nil
            self.selectedUC = nil
            
            self.regionDD.text = ""
            self.uCouncilDD.text = ""
            
            self.setupConstituencyDropdown()
            self.applyFilters()
        }
    }
    
    
    
    func setupConstituencyDropdown() {
        guard let affiliation = selectedAffiliation else { return }
        
        regionDD.optionArray = affiliation.constituencies.map { $0.name }
        
        regionDD.didSelect { [weak self] selectedText, index, id in
            guard let self = self else { return }
            
            self.selectedConstituency = affiliation.constituencies[index]
            self.regionDD.text = selectedText
            
            self.selectedUC = nil
            self.uCouncilDD.text = ""
            
            self.setupUnionCouncilDropdown()
            self.applyFilters()
        }
    }
    
    func setupUnionCouncilDropdown() {
        guard let constituency = selectedConstituency else { return }
        
        uCouncilDD.optionArray = constituency.unionCouncils.map { $0.name }
        
        uCouncilDD.didSelect { [weak self] selectedText, index, id in
            guard let self = self else { return }
            
            self.selectedUC = constituency.unionCouncils[index]
            self.uCouncilDD.text = selectedText
            
            self.applyFilters()
        }
    }
    
    func clearFilters() {
        selectedAffiliation = nil
        selectedConstituency = nil
        selectedUC = nil
        
        districtDD.text = ""
        regionDD.text = ""
        uCouncilDD.text = ""
        
        affiliations = allAffiliations
        tableView.reloadData()
    }
    
    
    @IBAction func filterBtnPressed(_ sender: UIButton) {
        clearFilters()
    }
    
    @IBAction func openMenu(_ sender: UIButton) {
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
    
    
    @IBAction func closeviewBtn(_ sender: UIButton) {
        shadowView.isHidden = true
    }
    
}


extension RegionsViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty {
            affiliations = allAffiliations
        } else {
            affiliations = allAffiliations.filter { affiliation in
                affiliation.name.localizedCaseInsensitiveContains(searchText) ||
                affiliation.constituencies.contains {
                    $0.name.localizedCaseInsensitiveContains(searchText) ||
                    $0.unionCouncils.contains {
                        $0.name.localizedCaseInsensitiveContains(searchText) ||
                        $0.wards.contains {
                            $0.name.localizedCaseInsensitiveContains(searchText)
                        }
                    }
                }
            }
        }
        
        tableView.reloadData()
    }
    
    
    func formatConstituencies(_ constituencies: [Constituency]) -> String {
        guard !constituencies.isEmpty else { return "—" }

        return constituencies
            .map { "• \($0.name)" }
            .joined(separator: "\n")
    }

    func formatUnionCouncils(_ constituencies: [Constituency]) -> String {
        let ucs = constituencies.flatMap { $0.unionCouncils }
        guard !ucs.isEmpty else { return "—" }

        return ucs
            .map { "• \($0.name)" }
            .joined(separator: "\n")
    }

    func formatWards(_ constituencies: [Constituency]) -> String {
        let wards = constituencies
            .flatMap { $0.unionCouncils }
            .flatMap { $0.wards }

        guard !wards.isEmpty else { return "—" }

        return wards
            .map { "• \($0.name)" }
            .joined(separator: "\n")
    }
    
    func formatHierarchy(for affiliation: Affiliation) -> String {

        var result = ""

        for constituency in affiliation.constituencies {
            result += "📍 Constituency: \(constituency.name)\n"

            for uc in constituency.unionCouncils {
                result += "   ▸ UC: \(uc.name)\n"

                for ward in uc.wards {
                    result += "      • \(ward.name)\n"
                }
            }

            result += "\n"
        }

        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }


}



extension RegionsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        affiliations.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "cell",
            for: indexPath
        ) as! regionsTableViewCell
        
        let affiliation = affiliations[indexPath.row]
        cell.configure(with: affiliation)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let affiliation = affiliations[indexPath.row]

        shadowView.isHidden = false

        regionLb.text = "Region: AJK"
        districtLb.text = "District: \(affiliation.name)"
        constintuteLb.text = formatHierarchy(for: affiliation)
//        constintuteLb.text = formatConstituencies(affiliation.constituencies)
//        unionCLb.text = formatUnionCouncils(affiliation.constituencies)
//        wardLb.text = formatWards(affiliation.constituencies)
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        110
    }
}
