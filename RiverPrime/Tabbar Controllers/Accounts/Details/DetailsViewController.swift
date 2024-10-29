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
        setHeaderValue()
    }
    
    func setHeaderValue() {
        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
            print("saved User Data: \(savedUserData)")
            // Access specific values from the dictionary
            
            if let loginID = savedUserData["loginId"] as? Int, let isCreateDemoAccount = savedUserData["demoAccountCreated"] as? Bool, let accountType = savedUserData["demoAccountGroup"] as? String, let isRealAccount = savedUserData["realAccountCreated"] as? Bool  {
                
                self.lbl_acctGroup.text = " \(accountType) "
                self.lbl_mt.text = " MT5 "
                
                self.lbl_loginID.text = "#\(loginID)"
                if isCreateDemoAccount {
                    self.lbl_acctType.text = " Demo "
                }
                if isRealAccount {
                    self.lbl_acctType.text = " Real "
                }
                
                if accountType == "Pro Account" {
                    self.lbl_acctGroup.text = " PRO "
                }else if accountType == "Prime Account" {
                    self.lbl_acctGroup.text  = " PRIME "
                }else if accountType == "Premium Account" {
                    self.lbl_acctGroup.text  = " PREMIUM "
                }
            }
        }
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
