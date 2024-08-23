//
//  NotificationViewController.swift
//  RiverPrime
//
//  Created by Ross Rostane on 15/07/2024.
//

import UIKit
import Foundation

class NotificationViewController: UIViewController {

    @IBOutlet weak var lbl_title: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func closeBtnAction(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            print("Bottom sheet dismissed after cross btn click")
        })
    }
    
    @IBAction func readAllBtnAction(_ sender: Any) {
        print("press read all button")
    }
}
