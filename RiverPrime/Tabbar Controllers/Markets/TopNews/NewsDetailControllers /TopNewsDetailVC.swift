//
//  TopNewsDetailVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 11/12/2024.
//

import UIKit
import QuartzCore

class TopNewsDetailVC: BaseViewController {

    @IBOutlet weak var firstIcon: UIImageView!
    @IBOutlet weak var secondIcon: UIImageView!
    @IBOutlet weak var thridIcon: UIImageView!
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var lbl_date: UILabel!
    @IBOutlet weak var lbl_category: UILabel!

    @IBOutlet weak var lbl_symbol: UILabel!

    @IBOutlet weak var textView_description: UITextView!

    var selectedItem: PayloadItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //MARK: - Hide Navigation Bar

        self.setNavBar(vc: self, isBackButton: false, isBar: false)
        self.setBarStylingForDashboard(animated: animated, view: self.view, vc: self, VC: MarketsViewController(), navController: self.navigationController, title: "NEWS Detail", leftTitle: "", rightTitle: "", textColor: .white, barColor: .clear)
    }
   
   func setupData() {
       lbl_title.text = selectedItem?.title
       let date = DateHelper.convertToDate(from: selectedItem?.date ?? "")
       lbl_date.text = DateHelper.timeAgo1(from: date!)
       lbl_symbol.text = "  " + (selectedItem?.symbol ?? "") + "  "
       lbl_symbol.layer.cornerRadius = 10.0
       self.lbl_category.layer.borderWidth = 0.2
       self.lbl_category.layer.borderColor = UIColor.lightGray.cgColor
       lbl_symbol.layer.masksToBounds = true
       if lbl_symbol.text == "" {
           lbl_symbol.text = ""
           self.lbl_symbol.layer.backgroundColor = UIColor.clear.cgColor
       }

       lbl_category.text = "  " + (selectedItem?.category ?? "") + "  "
       self.lbl_category.layer.cornerRadius = 10.0
//       self.lbl_category.layer.backgroundColor = UIColor.red.cgColor
       self.lbl_category.layer.borderWidth = 0.2
       self.lbl_category.layer.borderColor = UIColor.lightGray.cgColor
       self.lbl_category.layer.masksToBounds = true
       if lbl_category.text == "" {
           lbl_category.text = ""
           self.lbl_category.layer.backgroundColor = UIColor.clear.cgColor
           
       }
       
       self.textView_description.text = selectedItem?.description
       
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
