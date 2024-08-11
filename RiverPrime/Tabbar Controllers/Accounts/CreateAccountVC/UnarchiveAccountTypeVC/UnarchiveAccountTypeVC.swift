//
//  UnarchiveAccountTypeVC.swift
//  RiverPrime
//
//  Created by abrar ul haq on 11/08/2024.
//

import UIKit

class UnarchiveAccountTypeVC: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    var unarchiveTypes = "Real"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.font = FontController.Fonts.Inter_SemiBold.font
        
        registerCell()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //MARK: - Hide Navigation Bar
        self.setNavBar(vc: self, isBackButton: true, isBar: true)
    }
    
    @IBAction func addButton(_ sender: UIButton) {
        print(#function)
    }
    
    private func registerCell() {
        
        tableView.registerCells([
            UnarchiveAccountTypeTVC.self, UnarchiveAccountTypeDetailTVC.self
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
      
    }
    
}

extension UnarchiveAccountTypeVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
            return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 1
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(with: UnarchiveAccountTypeTVC.self, for: indexPath)
            cell.backgroundColor = .clear
            cell.delegate = self
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(with: UnarchiveAccountTypeDetailTVC.self, for: indexPath)
            cell.backgroundColor = .clear
            cell.textLabel?.font = FontController.Fonts.ListInter_SemiBold.font
            cell.detailTextLabel?.font = FontController.Fonts.ListInter_Regular.font
            cell.textLabel?.numberOfLines = 0
            cell.detailTextLabel?.numberOfLines = 0
            
            cell.textLabel?.text = "No \(self.unarchiveTypes) trading accounts yet"
            cell.detailTextLabel?.text = "Create account to get superior trading conditions for any strategy."
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 40.0
        } else if indexPath.section == 1 {
            return 300 //UITableView.automaticDimension //40
        } else {
            return 0
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension UnarchiveAccountTypeVC: UnarchiveDelegate {
    
    func UnarchivedTypeSelected(unarchiveTypes: UnarchiveTypes) {
//        tableView.reloadSections([1,2], with: .none)
        switch unarchiveTypes {
        case .Real:
            self.unarchiveTypes = "Real"
        case .Demo:
            self.unarchiveTypes = "Demo"
        case .Archived:
            self.unarchiveTypes = "Archived"
        }
        tableView.reloadSections([1], with: .none)
    }
    
}
