//
//  TopNewsViewController.swift
//  RiverPrime
//
//  Created by Ross Rostane on 11/12/2024.
//

import UIKit

class TopNewsViewController: BaseViewController {

    @IBOutlet weak var btn_allNews: UIButton!
    @IBOutlet weak var btn_favorites: UIButton!

    @IBOutlet weak var tableView_News: UITableView!
   
    var allPayloads : [PayloadItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Received Payloads: \(allPayloads)")
        
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
        self.setBarStylingForDashboard(animated: animated, view: self.view, vc: self, VC: MarketsViewController(), navController: self.navigationController, title: "", leftTitle: "", rightTitle: "", textColor: .lightGray, barColor: .clear)
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
       
        return allPayloads.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

            let cell = tableView.dequeueReusableCell(with: TopNewsTableViewCell.self, for: indexPath)
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
       
        let payload = allPayloads[indexPath.row]
        cell.lbl_title.text = payload.title
        
        cell.lbl_date.text = DateHelper.timeAgo(from: payload.date)
        
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
      
        let selectedItem = allPayloads[indexPath.row]
        if let vc = instantiateViewController(fromStoryboard: "Dashboard", withIdentifier: "TopNewsDetailVC") as? TopNewsDetailVC {
            
            vc.selectedItem = selectedItem
            self.navigate(to: vc)
        }
       
    }
}

