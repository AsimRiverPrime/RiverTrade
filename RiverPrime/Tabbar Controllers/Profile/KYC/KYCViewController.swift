//
//  KYCViewController.swift
//  RiverPrime
//
//  Created by Ross Rostane on 06/09/2024.
//

import UIKit
import iPass2_0NativeiOS

class KYCViewController: UIViewController {
    
    var appToken = "eyJhbGciOiJIUzI1NiJ9.aXRAc2FsYW1pbnYuY29tWmFpZCAgT2RlaCAgIGQ3NDU5ZjBlLTdmNWItNDhlNC04ZDAzLWE0YmJjNzMyNzE3Mg.QzQR-QHQM2kyYkdqUF9x0Te2L4m8aCQvU4E6bL_9KrY"
    var userToken = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      //  ActivityIndicator.shared.show(in: self.view)
        DataBaseDownloading.initialization(completion:{progres, status, error in
            print(progres, status, error)
           
//            if progres == "100%" {
//                ActivityIndicator.shared.hide(from: self.view)
//            }
        })
        
        iPassSDKManger.delegate = self
       
        login()
        
    }
    
    func login() {
        // User onboarding process to get user token
        iPassSDKManger.UserOnboardingProcess(email: "it@salaminv.com", password: "Salam@2022") { [weak self] status, tokenString in
            guard let self = self else { return }
            if status == true, let token = tokenString {
                self.userToken = token
                print("\n userToken is: \(self.userToken)")
              
            } else {
                print("Error: Failed to get user token")
            }
        }
    }
    
    @IBAction func closeBtn_action(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func handleDocumentUpload() async {
        if !userToken.isEmpty && !appToken.isEmpty {
            
                // Ensure the async SDK method is called on the main thread
              await  iPassSDKManger.startScanningProcess(
                    userEmail: "it@salaminv.com",
                    flowId: 10031,
                    socialMediaEmail: "Aasimali11991@gmail.com",
                    phoneNumber: "971561606314",
                    controller: self,
                    userToken: self.userToken,
                    appToken: self.appToken
                )
            
        } else {
            print("Error: Tokens are not set.")
        }
    }
    
    @IBAction func uploadDocBtn(_ sender: Any) {
      
        DispatchQueue.main.async {
            Task {
                await self.handleDocumentUpload()
                }
        }
       

    }
    
    
    func getFlows() async {
        let getList = iPassSDKManger.getWorkFlows()
        // Ensure any UI updates happen on the main thread
        DispatchQueue.main.async {
            print("the get list is: \(getList)")
        }
    }
}
// Delegate methods to handle scan completion
extension KYCViewController: iPassSDKManagerDelegate {
    
    
    func getScanCompletionResult(result: String, transactionId: String, error: String) {
        // Handle the result of the scanning process
        DispatchQueue.main.async {
            if error.isEmpty {
                print("Scan successful. Result: \(result), Transaction ID: \(transactionId)")
                // You can perform further actions here, such as notifying the user
                
                // if result sucess  then move to the CompleteVerificationProfileScreen1 for futher details 
            } else {
                print("Scan failed. Error: \(error)")
                // Handle the error, maybe show an alert to the user
            }
        }
    }
}
