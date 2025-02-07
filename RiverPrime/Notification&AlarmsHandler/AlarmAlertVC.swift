//
//  AlarmAlertVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 07/02/2025.
//

import UIKit

class AlarmAlertVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    @IBAction func closeBtnAction(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            print("Bottom sheet dismissed after cross btn click")
        })
    }

}
