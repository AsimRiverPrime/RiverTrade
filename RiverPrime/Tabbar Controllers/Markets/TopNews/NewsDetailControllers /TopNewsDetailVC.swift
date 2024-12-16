//
//  TopNewsDetailVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 11/12/2024.
//

import UIKit

class TopNewsDetailVC: BaseViewController {

    @IBOutlet weak var firstIcon: UIImageView!
    @IBOutlet weak var secondIcon: UIImageView!
    @IBOutlet weak var thridIcon: UIImageView!
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var lbl_date: UILabel!
    @IBOutlet weak var lbl_category: UILabel!

    @IBOutlet weak var lbl_symbol: UILabel!

    @IBOutlet weak var lbl_description: UILabel!

    var selectedItem: PayloadItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //MARK: - Hide Navigation Bar
        setupData()
//        
//        self.setNavBar(vc: self, isBackButton: false, isBar: false)
//        self.setBarStylingForDashboard(animated: animated, view: self.view, vc: self, VC: MarketsViewController(), navController: self.navigationController, title: "", leftTitle: "", rightTitle: "", textColor: .darkGray, barColor: .clear)
    }
   
   func setupData() {
       lbl_title.text = selectedItem?.title
       lbl_date.text = DateHelper.timeAgo(from: selectedItem?.date ?? "")
       lbl_symbol.text = " " + (selectedItem?.symbol ?? "") + " "
       lbl_symbol.layer.cornerRadius = 2
       lbl_category.text = " " + (selectedItem?.category ?? "") + " "
       lbl_category.layer.cornerRadius = 2
       lbl_description.text = selectedItem?.description
       
       switch selectedItem?.importance ?? 0 {
       case 1:
           firstIcon.image = UIImage(named: "fireIconSelect")
           secondIcon.image = UIImage(named: "fireIconSelect")?.tint(with: .lightGray)
           thridIcon.image = UIImage(named: "fireIconSelect")?.tint(with: .lightGray)
       case 2:
           firstIcon.image = UIImage(named: "fireIconSelect")
           secondIcon.image = UIImage(named: "fireIconSelect")
           thridIcon.image = UIImage(named: "fireIconSelect")?.tint(with: .lightGray)
       case 3:
           firstIcon.image = UIImage(named: "fireIconSelect")
           secondIcon.image = UIImage(named: "fireIconSelect")
           thridIcon.image = UIImage(named: "fireIconSelect")
       default:
           firstIcon.image = UIImage(named: "fireIconSelect")?.tint(with: .lightGray)
           secondIcon.image = UIImage(named: "fireIconSelect")?.tint(with: .lightGray)
           thridIcon.image = UIImage(named: "fireIconSelect")?.tint(with: .lightGray)
       }

    }

}
