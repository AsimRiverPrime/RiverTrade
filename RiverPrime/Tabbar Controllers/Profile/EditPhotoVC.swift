//
//  EditPhotoVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 19/11/2024.
//

import UIKit
import FirebaseStorage
import FirebaseFirestore
import SDWebImage

class EditPhotoVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var tf_username: UITextField!
    
    let imagePicker = UIImagePickerController()
    let storage = Storage.storage()
    let firestore = Firestore.firestore()
    let firebase = FirestoreServices()
    var userID = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        userImage.layer.cornerRadius = userImage.frame.height / 2
        userImage.clipsToBounds = true
        // Do any additional setup after loading the view.
        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
            print("saved User Data: \(savedUserData)")
           if let _name = savedUserData["name"] as? String , let _id = savedUserData["uid"] as? String, let _image = savedUserData["profileImageURL"] as? String {
               let imageUrl = URL(string: _image)
               userImage.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "avatarIcon"))
               
               self.tf_username.text = _name
               self.userID = _id
               
               
            }
        }
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
        
//        guard let username = tf_username.text else {
//            print("No userName enter")
//            return
//        }
        
        uploadImageToFirebaseStorage(image, self.tf_username.text ?? "")
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
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Firebase Storage Upload
    func uploadImageToFirebaseStorage(_ image: UIImage, _ name: String) {
        // Convert UIImage to Data
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Failed to convert image to data")
            return
        }
        
        // Create a unique filename
        let filename = "\(userID)_profile.jpg"
        
        // Reference to Firebase Storage
//        let storageRef = storage.reference().child("profile_images/\(filename)")
        let storageRef = Storage.storage().reference().child("profile_images/\(filename)")

        // Upload Image
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Failed to upload image: \(error.localizedDescription)")
                return
            }
            
            // Get Download URL
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Failed to get download URL: \(error.localizedDescription)")
                } else if let url = url {
                    print("Image uploaded successfully! URL: \(url.absoluteString)")
                    
                    self.saveImageURLToFirestore(url: url.absoluteString, name: name)
                }
            }
        }
    }
    
    // MARK: - Firestore Upload
    
    func saveImageURLToFirestore(url: String, name: String) {
        let userRef = firestore.collection("user").document(userID)
        
        userRef.setData(["profileImageURL": url, "name" : name], merge: true){ error in
            if let error = error {
                print("Failed to save image URL to Firestore: \(error.localizedDescription)")
            } else {
                print("Image URL successfully saved to Firestore!")
                self.firebase.fetchUserData(userId: self.userID)
            }
        }
    }
}
