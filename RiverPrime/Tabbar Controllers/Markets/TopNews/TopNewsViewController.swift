//
//  TopNewsViewController.swift
//  RiverPrime
//
//  Created by Ross Rostane on 11/12/2024.
//

import UIKit

class TopNewsViewController: UIViewController {

    @IBOutlet weak var btn_allNews: UIButton!
    @IBOutlet weak var btn_favorites: UIButton!

    @IBOutlet weak var tableView_News: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView_News.registerCells([
         TopNewsTableViewCell.self
            ])
       
        tableView_News.dataSource = self
        tableView_News.delegate = self
    }
    
    @IBAction func allNews_btnAction(_ sender: Any) {
        
    }
    
    @IBAction func favorites_btnAction(_ sender: Any) {
        
    }
    
}

extension TopNewsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
            return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
            return 10
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

            let cell = tableView.dequeueReusableCell(with: TopNewsTableViewCell.self, for: indexPath)
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      
            return 300
       
    }
    
}

