//
//  LogoutTableViewCell.swift
//  RiverPrime
//
//  Created by Ross Rostane on 23/07/2024.
//

import UIKit

class LogoutTableViewCell: UITableViewCell {

    @IBOutlet weak var lbl_email: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func logOutAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let loginVC = storyboard.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
        let loginVC = storyboard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        
        let navController = UINavigationController(rootViewController: loginVC)
        SCENE_DELEGATE.window?.rootViewController = navController
        SCENE_DELEGATE.window?.makeKeyAndVisible()
    }
    
}
