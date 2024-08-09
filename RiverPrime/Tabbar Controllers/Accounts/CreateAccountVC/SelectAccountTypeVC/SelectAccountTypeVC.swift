//
//  SelectAccountTypeVC.swift
//  RiverPrime
//
//  Created by abrar ul haq on 03/08/2024.
//

import UIKit

struct SelectAccountType {
    var title = String()
    var detail = String()
}

class SelectAccountTypeVC: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var selectAccountType = [SelectAccountType]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.font = FontController.Fonts.Inter_SemiBold.font
        
        setModel()
        registerCell()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //MARK: - Hide Navigation Bar
        self.setNavBar(vc: self, isBackButton: true, isBar: true)
    }
    
    private func setModel() {
        selectAccountType.removeAll()
        
        selectAccountType.append(SelectAccountType(title: "Demo account", detail: "Risk-free account. Trade with Virtual money."))
        selectAccountType.append(SelectAccountType(title: "Real account", detail: "Trade with real money and withdraw any profit you make."))
    }
    
    private func registerCell() {
        
        tableView.registerCells([
            SelectAccountTypeCell.self
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
      
    }
    
}

extension SelectAccountTypeVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
            return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectAccountType.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(with: SelectAccountTypeCell.self, for: indexPath)
        
        let model = selectAccountType[indexPath.row]
        
        cell.textLabel?.font = FontController.Fonts.ListInter_SemiBold.font
        cell.detailTextLabel?.font = FontController.Fonts.ListInter_Regular.font
        
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.numberOfLines = 0
        
        cell.textLabel?.text = model.title
        cell.detailTextLabel?.text = model.detail
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            //MARK: - Create demo account
            
//            let vc = Utilities.shared.getViewController(identifier: .createDemoAccountVC, storyboardType: .dashboard) as! CreateDemoAccountVC
//            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            let vc = Utilities.shared.getViewController(identifier: .createAccountSelectTradeType, storyboardType: .dashboard) as! CreateAccountSelectTradeType
            vc.preferredSheetSizing = .large
//            PresentModalController.instance.presentBottomSheet(self, VC: vc)
            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .customMedium, VC: vc)
            
        } else if indexPath.row == 1 {
            //MARK: - Create real account
            
        }
    }
}
