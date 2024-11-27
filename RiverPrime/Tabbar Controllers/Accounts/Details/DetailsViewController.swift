//
//  DetailsViewController.swift
//  RiverPrime
//
//  Created by Ross Rostane on 11/07/2024.
//

import UIKit

class DetailsViewController: UIViewController {

    @IBOutlet weak var lbl_loginID: UILabel!
    @IBOutlet weak var lbl_acctType: UILabel!
    @IBOutlet weak var lbl_mt: UILabel!
    @IBOutlet weak var lbl_acctGroup: UILabel!
    
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
        
        fundsV()
//        setHeaderValue()
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
        fundsButton.tintColor = .systemYellow
        settingsButton.tintColor = .white
        fundsUnderline.backgroundColor = .systemYellow
        settingsUnderline.backgroundColor = .lightGray
        
        settingsView.dismissView()
        fundsView.dismissView()
        fundsView = FundsView.getView()
        self.mainUIView.addSubview(fundsView)
        
    }
    
    private func settingsV() {
        settingsButton.tintColor = .systemYellow
        fundsButton.tintColor = .white
        fundsUnderline.backgroundColor = .lightGray
        settingsUnderline.backgroundColor = .systemYellow
        
        fundsView.dismissView()
        settingsView.dismissView()
        settingsView = SettingsView.getView()
        self.mainUIView.addSubview(settingsView)
        
    }
    
}
