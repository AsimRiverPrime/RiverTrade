//
//  DetailsViewController.swift
//  RiverPrime
//
//  Created by Ross Rostane on 11/07/2024.
//

import UIKit

class DetailsViewController: UIViewController {

    
    @IBOutlet weak var fundsUnderline: UIView!
    @IBOutlet weak var settingsUnderline: UIView!
    @IBOutlet weak var fundsButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    //    @IBOutlet weak var detail_tableView: UITableView!
    @IBOutlet weak var mainUIView: UIView!
    
    var fundsView = FundsView()
    var settingsView = SettingsView()
   
    override func viewDidLoad() {
        super.viewDidLoad()

        
//        detail_tableView.registerCells([
//            AccountTableViewCell.self, ListingTableViewCell.self
//        ])
//        detail_tableView.delegate = self
//        detail_tableView.dataSource = self
//        detail_tableView.reloadData() 
        
        fundsV()
        
    }
    
    override func viewDidLayoutSubviews() {
        fundsView.frame = self.view.bounds
        settingsView.frame = self.view.bounds
    }
    
    @IBAction func fundsButton(_ sender: UIButton) {
        fundsV()
    }
    
    @IBAction func settingsButton(_ sender: UIButton) {
        settingsV()
    }
    
    private func fundsV() {
        
        fundsUnderline.backgroundColor = .systemYellow
        settingsUnderline.backgroundColor = .lightGray
        
        settingsView.dismissView()
        fundsView.dismissView()
        fundsView = FundsView.getView()
        self.mainUIView.addSubview(fundsView)
        
    }
    
    private func settingsV() {
        
        fundsUnderline.backgroundColor = .lightGray
        settingsUnderline.backgroundColor = .systemYellow
        
        fundsView.dismissView()
        settingsView.dismissView()
        settingsView = SettingsView.getView()
        self.mainUIView.addSubview(settingsView)
        
    }
    
}
//extension DetailsViewController: UITableViewDelegate, UITableViewDataSource {
//    func numberOfSections(in tableView: UITableView) -> Int {
//           return 2
//    }
//        
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if section == 0 {
//            return 1
//        }else{
//            return 2
//        }
//    }
//        
//        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//            
//            if indexPath.section == 0 {
//                let cell = tableView.dequeueReusableCell(with: AccountTableViewCell.self, for: indexPath)
//                cell.setHeaderUI(.detail)
////                cell.delegate = self
//                
//                return cell
//            } else  {
//                let cell = tableView.dequeueReusableCell(with: ListingTableViewCell.self, for: indexPath)
//                    return cell
//            }
//            
//            
//        }
//        
//        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//            if indexPath.section == 0 {
//                return 300.0
//            }else{
//                return 200.0
//            }
//        }
//        
//    
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        
//        
//    }
//    
//    
//}
