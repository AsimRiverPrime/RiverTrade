//
//  EditPhotoVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 19/11/2024.
//

import UIKit
//import FirebaseStorage
import FirebaseFirestore
import SDWebImage

class EditPhotoVC: BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var tf_username: UITextField!
    
    let imagePicker = UIImagePickerController()
    
    //    let odooClient = OdooClientNew()
    let firebase = FirestoreServices()
    var userID : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        userImage.layer.cornerRadius = userImage.frame.height / 2
        userImage.clipsToBounds = true
        // Do any additional setup after loading the view.
        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
            //print("saved User Data: \(savedUserData)")
            if let _name = savedUserData["fullName"] as? String , let _id = savedUserData["uid"]  as? String{
                
                self.tf_username.text = _name
                self.userID = _id
                
                if let imageData = UserDefaults.standard.data(forKey: "userProfileImage"),
                   let savedImage = UIImage(data: imageData) {
                    userImage.image = savedImage
                }else{
                    userImage.image = UIImage(systemName: "person.circle")
                }
                
            }
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //MARK: - Hide Navigation Bar

        self.setNavBar(vc: self, isBackButton: false, isBar: false)
        self.setBarStylingForDashboard(animated: animated, view: self.view, vc: self, VC: ProfileViewController(), navController: self.navigationController, title: "Edit Name/Image", leftTitle: "", rightTitle: "", textColor: .white, barColor: .black)
    }
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func editPhoto_action(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Select Image", message: "Choose an image source", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
            self.openPhotoLibrary()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func saveChange_action(_ sender: Any) {
        guard let image = userImage.image else {
            print("No image to upload")
            return
        }
        
        guard let username = tf_username.text else {
            print("No userName enter")
            return
        }
        updateUser()
        //        odooClient.writeName_toCRM(name: tf_username.text ?? "")
        
        let _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
            print("Timer fired!")
            
            NotificationCenter.default.post(name: Notification.Name("UpdateProfileData"), object: nil, userInfo: [
                "profileImage": image,
                "userName": username
            ])
            
            self?.navigationController?.popViewController(animated: true)
        }
        
    }
    
    
    func updateUser() {
        guard let userId = userID else {
            print("No user ID to update")
            return
        }
        var fieldsToUpdate: [String: Any] = [
            "fullName": self.tf_username.text
        ]
        
        firebase.updateUserFields(userID: userId, fields: fieldsToUpdate) { error in
            if let error = error {
                print("Error updating user fields: \(error.localizedDescription)")
                return
            } else {
                print("\n Data Update successfully to fireBase")
                self.firebase.fetchUserData(userId: userId )
            }
        }
    }
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            print("Camera not available")
        }
    }
    
    func openPhotoLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            print("Photo Library not available")
        }
    }
    
    // MARK: - UIImagePickerController Delegate Methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            userImage.image = selectedImage
            // Convert the image to Data
            if let imageData = selectedImage.jpegData(compressionQuality: 1.0) {
                // Save the image data to UserDefaults
                UserDefaults.standard.set(imageData, forKey: "userProfileImage")
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
