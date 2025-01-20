//
//  TopNewsViewController.swift
//  RiverPrime
//
//  Created by Ross Rostane on 11/12/2024.
//

import UIKit

class TopNewsViewController: BaseViewController {

    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var tableView_News: UITableView!
    @IBOutlet weak var searchCloseButton: UIButton!

    
    var allPayloads : [PayloadItem] = []
    var filteredData: [PayloadItem] = []
    
    var getAllPayloads: [PayloadItem] {
        return filteredData.isEmpty ? allPayloads : filteredData
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Received Payloads: \(getAllPayloads)")
        self.searchCloseButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)

        self.searchTF.delegate = self
        // Add a target to update search on text change
        self.searchTF.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)
        
        tableView_News.registerCells([
         TopNewsTableViewCell.self
            ])
       
        tableView_News.dataSource = self
        tableView_News.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //MARK: - Hide Navigation Bar
        
        self.setNavBar(vc: self, isBackButton: false, isBar: false)
        self.setBarStylingForDashboard(animated: animated, view: self.view, vc: self, VC: MarketsViewController(), navController: self.navigationController, title: "NEWS", leftTitle: "", rightTitle: "", textColor: .white, barColor: .clear)
    }
    
    @IBAction func searchClose_action(_ sender: Any) {
        if searchTF.text != "" {
            self.searchCloseButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
            searchTF.text = ""
            searchTextChanged()
        }else{
            self.searchCloseButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
            return
        }
       
    }
    func sortLatestDate () {
        allPayloads.sort { payload1, payload2 in
            guard let date1 = DateHelper.convertToDate(from: payload1.date),
                  let date2 = DateHelper.convertToDate(from: payload2.date) else { return false }
            return date1 > date2
        }
    }
    
}

extension TopNewsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
            return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return getAllPayloads.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        tableView.keyboardDismissMode = .onDrag
        
        let cell = tableView.dequeueReusableCell(with: TopNewsTableViewCell.self, for: indexPath)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        let payload = getAllPayloads[indexPath.row]
        cell.lbl_title.text = payload.title
        
        let date = DateHelper.convertToDate(from: payload.date)
        cell.lbl_date.text = DateHelper.timeAgo1(from: date!)
        
//        cell.lbl_date.text = DateHelper.timeAgo(from: payload.date)
        
        switch payload.importance {
        case 1:
            cell.firstIcon.image = UIImage(named: "fireIconSelect")
            cell.secondIcon.image = UIImage(named: "fireIconSelect")?.tint(with: .lightGray)
            cell.thridIcon.image = UIImage(named: "fireIconSelect")?.tint(with: .lightGray)
        case 2:
            cell.firstIcon.image = UIImage(named: "fireIconSelect")
            cell.secondIcon.image = UIImage(named: "fireIconSelect")
            cell.thridIcon.image = UIImage(named: "fireIconSelect")?.tint(with: .lightGray)
        case 3:
            cell.firstIcon.image = UIImage(named: "fireIconSelect")
            cell.secondIcon.image = UIImage(named: "fireIconSelect")
            cell.thridIcon.image = UIImage(named: "fireIconSelect")
        default:
            cell.firstIcon.image = UIImage(named: "fireIconSelect")?.tint(with: .lightGray)
            cell.secondIcon.image = UIImage(named: "fireIconSelect")?.tint(with: .lightGray)
            cell.thridIcon.image = UIImage(named: "fireIconSelect")?.tint(with: .lightGray)
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
        let selectedItem = getAllPayloads[indexPath.row]
        if let vc = instantiateViewController(fromStoryboard: "Dashboard", withIdentifier: "TopNewsDetailVC") as? TopNewsDetailVC {
            
            vc.selectedItem = selectedItem
            self.navigate(to: vc)
        }
       
    }
}

extension TopNewsViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == searchTF {
//            symbolDataSector.removeAll()
//            //MARK: - Set all sectors by default.
//            symbolDataSector = GlobalVariable.instance.sectors
//            filteredData = []
//            tblView.isHidden = true
//            tblSearchView.isHidden = false
//            self.searchCloseButton.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
//            tblSearchView.delegate = self
//            tblSearchView.dataSource = self
//            tblSearchView.reloadData()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == searchTF {
            if textField.text == "" {
//                symbolDataSector.removeAll()
//                //MARK: - Set all sectors by default.
//                symbolDataSector = GlobalVariable.instance.sectors
//                tblSearchView.delegate = self
//                tblSearchView.dataSource = self
//                tblSearchView.reloadData()
            }
        }
    }
    
    // UITextField target method to handle text changes
    @objc func searchTextChanged() {
        // Filter the data based on the search text
        let searchText = searchTF.text?.lowercased() ?? ""
        
        if searchText.isEmpty {
            filteredData = []  // Clear the filtered data when search text is empty
            self.searchCloseButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)

        } else {
            self.searchCloseButton.setImage(UIImage(systemName: "xmark.circle"), for: .normal)

            // Filter the allPayloads array based on the search text
            filteredData = allPayloads.filter { payload in
                return payload.title.lowercased().contains(searchText.lowercased()) ||
                payload.description.lowercased().contains(searchText.lowercased())
            }
        }
        
        // Reload the table view to reflect the search results
        tableView_News.reloadData()
        
//        if searchText.isEmpty {
//            filteredData = [] // If the search text is empty, show all data
////            symbolDataSectorSelected = false
//        } else {
//
//            // If no sector is selected, filter symbols across all sectors
//            let filteredSymbols = symbolDataSector.flatMap { sectorGroup in
//                sectorGroup.symbols.filter { $0.name.lowercased().contains(searchText) }
//            }
//
//            // Regroup filtered symbols into their respective sectors
//            filteredData = symbolDataSector.compactMap { sectorGroup in
//                let filteredSectorSymbols = filteredSymbols.filter { $0.sector == sectorGroup.sector }
//                return filteredSectorSymbols.isEmpty ? nil : SectorGroup(sector: sectorGroup.sector, symbols: filteredSectorSymbols)
//            }
////
////            symbolDataSectorSelected = true
//        }
//
////        tblSearchView.delegate = self
////        tblSearchView.dataSource = self
////        // Reload the table view to show the filtered data
////        tblSearchView.reloadData()
    }
    
    // Optional: Dismiss the keyboard when the user taps 'Return'
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

