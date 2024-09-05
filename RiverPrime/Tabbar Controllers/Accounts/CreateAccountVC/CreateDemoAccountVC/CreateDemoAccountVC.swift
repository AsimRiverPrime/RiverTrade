//
//  CreateDemoAccountVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 04/08/2024.
//

import UIKit

class CreateDemoAccountVC: BaseViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setStyle()
        registerTableView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //MARK: - Hide Navigation Bar
        self.setNavBar(vc: self, isBackButton: true, isBar: true)
    }
    
    @IBAction func settingButton(_ sender: UIButton) {
        print(#function)
        
    }
    
}

extension CreateDemoAccountVC {
    
    private func registerTableView() {
        
        tableView.registerCells([
            CreateAccountSlideCell.self
        ])
      
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        
    }
    
    private func setStyle() {
        titleLabel.font = FontController.Fonts.Inter_SemiBold.font
        
        settingButton.setTitle("", for: .normal)
        
    }
    
}

extension CreateDemoAccountVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
            return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
//            let cell = tableView.dequeueReusableCell(with: CreateAccountSlideCell.self, for: indexPath)
            let cell = CreateAccountSlideCell.cellForTableView(tableView, atIndexPath: indexPath)
            
            return cell
            
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 400.0
        }
        
        return 0
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}
