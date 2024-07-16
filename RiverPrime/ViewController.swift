//
//  ViewController.swift
//  RiverPrime
//
//  Created by Ross Rostane on 08/07/2024.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func registerBtn(_ sender: Any) {
        if let signUp = instantiateViewController(fromStoryboard: "Main", withIdentifier: "SignUpViewController"){
            self.navigate(to: signUp)
        }
    }
}

