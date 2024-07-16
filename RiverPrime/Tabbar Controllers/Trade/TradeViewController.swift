//
//  TradeViewController.swift
//  RiverPrime
//
//  Created by Ahmad on 13/07/2024.
//

import UIKit

class TradeViewController: UIViewController {
    @IBOutlet weak var tblView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tblView.registerCells([
            AccountTableViewCell.self
            ])
        tblView.reloadData()

    }
    

}

extension TradeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
            return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(with: AccountTableViewCell.self, for: indexPath)
        cell.setHeaderUI(.trade)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}
