//
//  LogoutTableViewCell.swift
//  RiverPrime
//
//  Created by Ross Rostane on 23/07/2024.
//

import UIKit

class LogoutTableViewCell: UITableViewCell {

    @IBOutlet weak var lbl_email: UILabel!
    
    var userId : String?
    let fireStoreInstance = FirestoreServices()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
            print("saved User Data: \(savedUserData)")
            // Access specific values from the dictionary
            
            if let _email = savedUserData["email"] as? String , let _userId = savedUserData["uid"] as? String{
                self.lbl_email.text = _email
                self.userId = _userId
               // print("\n userId: \(userId) and userId_firebase: \(userId1)")
            }
        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func logOutAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let loginVC = storyboard.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
// update the firebase as well login
        UserDefaults.standard.removeObject(forKey: "userData")
        
        let loginVC = storyboard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        
        let navController = UINavigationController(rootViewController: loginVC)
        SCENE_DELEGATE.window?.rootViewController = navController
        SCENE_DELEGATE.window?.makeKeyAndVisible()
    }
    
    func updateUser() {
        
        guard let userId = userId else{
            return
        }
        var fieldsToUpdate: [String: Any] = [
                
                "login" : false
             ]
        
        fireStoreInstance.updateUserFields(userID: userId, fields: fieldsToUpdate) { error in
            if let error = error {
                print("Error updating user fields: \(error.localizedDescription)")
                return
            } else {
                print("\n User data save successfully in the fireBase")
            }
        }
    }
    
}
