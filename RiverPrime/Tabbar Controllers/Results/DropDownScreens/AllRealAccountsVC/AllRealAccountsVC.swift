//
//  AllRealAccountsVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 13/08/2024.
//

import UIKit

class AllRealAccountsVC: BottomSheetController {

    @IBOutlet weak var mySegmentControl: CustomSegmentedControl! {
        didSet{
            mySegmentControl.setButtonTitles(buttonTitles: ["Real", "Archived"])
            mySegmentControl.selectorViewColor = .systemYellow
            mySegmentControl.selectorTextColor = .black
        }
    }
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tblView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mySegmentControl.delegate = self
        
        tblView.registerCells([
            AccountDetailTVC.self
        ])
        
        tblView.delegate = self
        tblView.dataSource = self
        tblView.reloadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setNavBar(vc: self, isBackButton: true, isBar: true)
    }
    
}

extension AllRealAccountsVC: CustomSegmentedControlDelegate {
 
    func change(to index: Int) {
        print("index = \(index)")
        var getName = ""
        if index == 0 {
            getName = "real"
        } else {
            getName = "archived"
        }
        titleLabel.text = "All \(getName) accounts"
    }
    
}

extension AllRealAccountsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: AccountDetailTVC.self, for: indexPath)
        cell.backgroundColor = .clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
}
