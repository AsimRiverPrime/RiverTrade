//
//  WithdrawPreRequirmentVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 29/01/2025.
//

import UIKit
import SDWebImage

class WithdrawPreRequirmentVC: BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
   
    @IBOutlet weak var userImage: UIImageView!
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //MARK: - Hide Navigation Bar
        self.setNavBar(vc: self, isBackButton: false, isBar: false)
        self.setBarStylingForDashboard(animated: animated, view: self.view, vc: self, VC: AccountsViewController(), navController: self.navigationController, title: "Upload Utility Bill", leftTitle: "", rightTitle: "", textColor: .white, barColor: .black)
    }
    @IBAction func submitDocument(_ sender: Any) {
        self.dismiss(animated: true)
//        UserDefaults.standard.set(false, forKey: "hasUploadBill")
        UserDefaults.standard.set(true, forKey: "hasUploadBill")
        let vc = Utilities.shared.getViewController(identifier: .withdrawViewController, storyboardType: .dashboard) as! WithdrawViewController
        PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
//        if let vc = instantiateViewController(fromStoryboard: "Dashboard", withIdentifier: "WithdrawViewController") as? WithdrawViewController {
//            self.navigate(to: vc)
//        }
        
    }
    
    @IBAction func uploadDocument(_ sender: Any) {
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
