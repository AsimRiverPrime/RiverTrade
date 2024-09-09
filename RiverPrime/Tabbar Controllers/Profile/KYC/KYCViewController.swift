//
//  KYCViewController.swift
//  RiverPrime
//
//  Created by Ross Rostane on 06/09/2024.
//

import UIKit
import iPass2_0NativeiOS

class KYCViewController: UIViewController, iPassSDKDelegate {
    func getScanCompletionResult(result: String, error: String) {
        print("\n the result is: \(result)")
        print("\n the result error is: \(error)")
    }
    
    
    
    var appToken = "eyJhbGciOiJIUzI1NiJ9.aXRAc2FsYW1pbnYuY29tWmFpZCAgT2RlaCAgIGQ3NDU5ZjBlLTdmNWItNDhlNC04ZDAzLWE0YmJjNzMyNzE3Mg.QzQR-QHQM2kyYkdqUF9x0Te2L4m8aCQvU4E6bL_9KrY"
    var userToken = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DataBaseDownloading.initialization(completion:{progres, status, error in
                            print(progres, status, error)
                        })
        
        iPassSDKManger.delegate = self
        iPassSDK.delegate = self
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
    
    @IBAction func uploadDocBtn(_ sender: Any) {
        
        Task {
              if !userToken.isEmpty && !appToken.isEmpty {
                  // Ensure the controller (UI related) is accessed on the main thread
                  let controller = await MainActor.run {
                      return self  // Access 'self' (UIViewController) on the main thread
                  }
                  
                  // Call the SDK method with the UI controller obtained on the main thread
                  await iPassSDKManger.startScanningProcess(
                      userEmail: "it@salaminv.com",
                      flowId: 10031,
                      socialMediaEmail: "Aasimali11991@gmail.com",
                      phoneNumber: "971561606314",
                      controller: self,  // Pass the controller obtained on the main thread
                      userToken: self.userToken,
                      appToken: self.appToken
                  )
              } else {
                  print("Error: Tokens are not set.")
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
            } else {
                print("Scan failed. Error: \(error)")
                // Handle the error, maybe show an alert to the user
            }
        }
    }
}
