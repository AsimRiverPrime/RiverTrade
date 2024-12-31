//
//  FireStoreService.swift
//  RiverPrime
//
//  Created by Ross Rostane on 26/07/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import Firebase


class FirestoreServices: BaseViewController {
    
    var window: UIWindow?
    
    let db = Firestore.firestore()
   
    var odoClientNew = OdooClientNew()
    var accounts: [AccountModel] = []
    
    func addUser(_ user: UserModel, completion: @escaping (Error?) -> Void) {
        let userRef = db.collection("users").document(user.uid)
        userRef.setData(user.toDictionary(), completion: completion)
    }
    
    func addUserAccountData(uid: String, data: [String: Any], completion: @escaping (Result<Void, Error>) -> Void) {
           // Add a new document in collection "userAccount"
           db.collection("userAccount").document(uid).setData(data, merge: true) { error in
               if let error = error {
                   completion(.failure(error))
               } else {
                   completion(.success(()))
               }
           }
    }
    
    func saveAdditionalUserData(userId: String, kyc: String, address: String, dateOfBirth: String, profileStep: Int, name: String, gender: String, phone: String, email: String, emailVerified: Bool, phoneVerified:Bool, isLogin: Bool, pushedToCRM:Bool, nationality: String, residence : String, registrationType: Int) {
        
        db.collection("users").document(userId).setData([
            "KycStatus" : kyc,
            "address": address,
            "dateOfBirth": dateOfBirth,
            "email":email,
            "emailVerified": emailVerified,
            
            "fullName": name,
            "gender" : gender,
            "id": userId,
            "isLogin": isLogin,
            "nationality": nationality,
            
            "phone": phone,
            "phoneVerified": phoneVerified,
            "profileStep" : profileStep,
            "pushedToCRM": pushedToCRM,
            "registrationType": registrationType,
            "residence": residence
            
//            "userName" : userName,
//            "loginId": loginId,
//            "demoAccountGroup": demoAccountGroup,
//            "realAccountCreated": realAccountCreated,
//            "demoAccountCreated": demoAccountCreated,
            
        ]) { error in
            if let error = error {
                print("Error saving user data: \(error.localizedDescription)")
            } else {
                print("User data saved successfully.")
            }
        }
        fetchUserData(userId: userId)
    }

       
    func fetchUserData(userId: String) {
        UserDefaults.standard.set(userId, forKey: "userID")
        print("user ID is: \(userId)")
        
         let docRef = db.collection("users").document(userId)
         
         docRef.getDocument { (document, error) in
             if let document = document, document.exists {
                 print("User document exist and data is: \(document) ")
                 if let data = document.data() {
                   
                     print("data is: \(data)")
                     UserDefaults.standard.set(data, forKey: "userData")
                 }
             } else {
                 print("User document does not exist: \(error?.localizedDescription ?? "Unknown error")")

             }
         }
     }
    
    func fetchUserAccountsData(userId: String, completion: @escaping () -> Void) {
        // Save userID in UserDefaults
        UserDefaults.standard.set(userId, forKey: "userID")
        print("User ID is: \(userId)")
        
        // Firestore query with `where` clause
        let query = db.collection("userAccounts").whereField("userID", isEqualTo: userId)
        
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching user accounts: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                print("No user accounts found for the given userID.")
                GlobalVariable.instance.isAccountCreated = false
                return
            }
            
            var userAccountsData = [String: [String: Any]]() // Dictionary to store all documents' data
            
            for document in documents {
                let documentId = document.documentID
                let data = document.data()
                userAccountsData[documentId] = data
            }
            
            // Save the combined data in UserDefaults
            UserDefaults.standard.set(userAccountsData, forKey: "userAccountsData")
            print("Combined User Accounts data saved: \(userAccountsData)")
            // Update accounts
            UserAccountManager.shared.updateAccounts(from: userAccountsData)

            // Retrieve and print the default account
            if let defaultAccount = UserAccountManager.shared.getDefaultAccount() {
                print("\n Default user Account : \(defaultAccount)")
               
            }
            
            if userAccountsData.count == 0 {
                GlobalVariable.instance.isAccountCreated = false
            }else{
                GlobalVariable.instance.isAccountCreated = true
            }
            completion()
        }
    }
    
    func fetchUserAccountsData(userId: String) {
        // Save userID in UserDefaults
        UserDefaults.standard.set(userId, forKey: "userID")
        print("User ID is: \(userId)")
        
        // Firestore query with `where` clause
        let query = db.collection("userAccounts").whereField("userID", isEqualTo: userId)
        
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching user accounts: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                print("No user accounts found for the given userID.")
                GlobalVariable.instance.isAccountCreated = false
                return
            }
            
            var userAccountsData = [String: [String: Any]]() // Dictionary to store all documents' data
            
            for document in documents {
                let documentId = document.documentID
                let data = document.data()
                userAccountsData[documentId] = data
            }
            
            // Save the combined data in UserDefaults
            UserDefaults.standard.set(userAccountsData, forKey: "userAccountsData")
            print("Combined User Accounts data saved: \(userAccountsData)")
            // Update accounts
            UserAccountManager.shared.updateAccounts(from: userAccountsData)

            // Retrieve and print the default account
            if let defaultAccount = UserAccountManager.shared.getDefaultAccount() {
                print("\n Default user Account : \(defaultAccount)")
               
            }
            
            if userAccountsData.count == 0 {
                GlobalVariable.instance.isAccountCreated = false
            }else{
                GlobalVariable.instance.isAccountCreated = true
            }
        }
    }

   
    
    func fetchAccountsGroup(completion: @escaping ([AccountModel]) -> Void) {
        db.collection("accountsGroup").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error.localizedDescription)")
                completion([])
                return
            }

            for document in querySnapshot!.documents {
                let data = document.data()
                if let account = try? AccountModel(
                    id: document.documentID,
                    tradingInstruments: data["tradingInstruments"] as? String ?? "",
                    spreadsFrom: data["spreadsFrom"] as? String ?? "",
                    startingDeposit: data["startingDeposit"] as? Int ?? 0,
                    order: data["order"] as? Int ?? 0,
                    accountCurrency: data["accountCurrency"] as? String ?? "",
                    EA: data["EA"] as? Int ?? 0,
                    minimumOrderSize: data["minimumOrderSize"] as? Double ?? 0.0,
                    islamicAccounts: data["islamicAccounts"] as? Int ?? 0,
                    name: data["name"] as? String ?? "",
                    platform: data["platform"] as? String ?? "",
                    stopOutLevel: data["stopOutLevel"] as? String ?? "",
                    orderExecution: data["orderExecution"] as? String ?? "",
                    commission: data["commission"] as? Int ?? 0,
                    recommended: data["recommended"] as? Int ?? 0,
                    hedging: data["hedging"] as? Int ?? 0,
                    leverage: data["leverage"] as? String ?? ""
                ) {
                    self.accounts.append(account)
                }
            }
            print("accountGroup data:\(self.accounts)")
            completion(self.accounts)
        }
    }
    
    func handleUserData() {
        if let data = UserDefaults.standard.dictionary(forKey: "userData") {
            print("\n Handle saved User Data for navigation : \(data)")
            
            if let emailVerified = data["emailVerified"] as? Bool, !emailVerified {
                if let email = data["email"] as? String {
                    odoClientNew.sendOTP(type: "email", email: email , phone: "")
                   
                }
               navigateToEmailVerificationScreen()
                print("navigate to user email verification")
               
//            } else if let phoneVerified = data["phone"] as? String, phoneVerified == "" {
//               navigateToPhoneVerificationScreen()
//                print("/n navigate to user phone verification")
            } else if let demoAccountCreated = data["demoAccountCreated"] as? Bool, !demoAccountCreated {
                navigateToDemoAccountCreationScreen()
                print("navigate to user demo account")
//            } else if let profileStep = data["demoAccountCreated"] as? Int {
//                print("check profile step: \(profileStep)")
            } else {
                print("navigate to Main dashboard")
                navigateToDemoAccountCreationScreen()
            }
        }
  }
    
    func checkUserExists(withID id: String, completion: @escaping (Bool) -> Void) {
        let userRef = db.collection("users").document(id)
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func updateUserFields(userID: String, fields: [String: Any], completion: @escaping (Error?) -> Void) {
           let userRef = db.collection("users").document(userID)
           userRef.updateData(fields, completion: completion)
       }
    
    func updateUserAccountsFields(fields: [String: Any], completion: @escaping (Error?) -> Void) {
        let uniqueId = db.collection("userAccounts").document().documentID
        let userRef = db.collection("userAccounts").document(uniqueId)
        userRef.setData(fields, completion: completion)
    }
    
    func updateDefaultAccount(for accountKey: String, userId: String, completion: @escaping (Error?) -> Void) {
        print("Updating default account for accountKey: \(accountKey), userId: \(userId)")

        // Retrieve accounts from UserDefaults
        guard var accountsDict = UserDefaults.standard.dictionary(forKey: "userAccountsData") as? [String: [String: Any]] else {
            print("No accounts found in UserDefaults. Fetching data...")
            fetchUserAccountsData(userId: userId){
                self.updateDefaultAccount(for: accountKey, userId: userId, completion: completion)
            }
           
            return
        }

        // Update the `isDefault` flag in UserDefaults
//        print("Before update in UserDefaults: \(accountsDict)")
        for (key, account) in accountsDict {
            if var accountData = account as? [String: Any],
               let accountUserID = accountData["userID"] as? String,
               let accountNumber = accountData["accountNumber"] as? Int {
                
                let isMatchingAccount = (accountNumber == Int(accountKey))
                let isMatchingUser = (accountUserID == userId)

                print("Key: \(key), accountNumber: \(accountNumber), isMatchingAccount: \(isMatchingAccount), accountUserID: \(accountUserID), isMatchingUser: \(isMatchingUser)")

                accountData["isDefault"] = (isMatchingAccount && isMatchingUser) ? 1 : 0
                accountsDict[key] = accountData
            } else {
                print("Key \(key) is missing accountNumber, userID, or account data.")
            }
        }
//        print("After update in UserDefaults: \(accountsDict)")

        // Save updated accounts back to UserDefaults
        UserDefaults.standard.set(accountsDict, forKey: "userAccountsData")
        UserDefaults.standard.synchronize()

        // Update the `isDefault` flag in Firebase
        let batch = self.db.batch()

        for (key, account) in accountsDict {
            if let accountUserID = account["userID"] as? String, accountUserID == userId {
                let isDefault = account["isDefault"] as? Int ?? 0
                print("Setting isDefault in Firebase for accountKey \(key): \(isDefault)")
                let docRef = self.db.collection("userAccounts").document(key)
                batch.setData(["isDefault": isDefault], forDocument: docRef, merge: true)
            }
        }

        // Commit the batch
        batch.commit { error in
            if let error = error {
                print("Error updating Firebase: \(error.localizedDescription)")
                completion(error)
            } else {
                print("Successfully updated isDefault in Firebase")
                self.fetchUserAccountsData(userId: userId) {
                    completion(nil)
                }
//                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                  
//                }
            }
        }
    }


    func deleteAllUserAccounts(for userId: String, completion: @escaping (Error?) -> Void) {
        let userAccountsCollection = db.collection("userAccounts")
        
        // Query documents where userID matches the specified value
        userAccountsCollection.whereField("userID", isEqualTo: userId).getDocuments { querySnapshot, error in
            if let error = error {
                print("Error fetching user accounts: \(error.localizedDescription)")
                completion(error)
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No user accounts found for userID: \(userId)")
                completion(nil)
                return
            }
            
            // Delete each document
            let dispatchGroup = DispatchGroup()
            for document in documents {
                dispatchGroup.enter()
                document.reference.delete { error in
                    if let error = error {
                        print("Error deleting document: \(error.localizedDescription)")
                    }
                    dispatchGroup.leave()
                }
            }
            
            // Notify when all deletions are completed
            dispatchGroup.notify(queue: .main) {
                print("All user accounts deleted for userID: \(userId)")
                completion(nil)
            }
        }
    }

    //MARK: Get data from the Firebase Firestore by email and UserID
    func getUserDataByEmail(email: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        let usersRef = db.collection("users")
        let query = usersRef.whereField("email", isEqualTo: email)
        
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user found with this email."])))
                    return
                }
                
                // Assuming email is unique, we take the first document
                let document = documents.first!
                let data = document.data()
                completion(.success(data))
            }
        }
    }
    
    func getUserData(userId: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        let docRef = db.collection("users").document(userId)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let data = document.data() {
                    completion(.success(data))
                } else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Document data was empty."])))
                }
            } else {
                completion(.failure(error ?? NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Document does not exist."])))
            }
        }
    }
    
    func getAllUsers(completion: @escaping (Result<[[String: Any]], Error>) -> Void) {
        db.collection("users").getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                var users: [[String: Any]] = []
                for document in querySnapshot!.documents {
                    users.append(document.data())
                }
                completion(.success(users))
            }
        }
    }
   
       
       private func navigateToMainScreen() {
           let storyboard = UIStoryboard(name: "Dashboard", bundle: nil)
//           let mainVC = storyboard.instantiateViewController(withIdentifier: "DashboardVC") as! DashboardVC
           let mainVC = storyboard.instantiateViewController(withIdentifier: "HomeTabbarViewController") as! HomeTabbarViewController
           self.navigationController?.pushViewController(mainVC, animated: true)
//           window?.rootViewController = mainVC
//           window?.makeKeyAndVisible()
       }

        func navigateToLoginScreen() {
//           let storyboard = UIStoryboard(name: "Main", bundle: nil)
//           let loginVC = storyboard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
//           self.navigationController?.pushViewController(loginVC, animated: true)
            
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
            
            let navController = UINavigationController(rootViewController: loginVC)
            SCENE_DELEGATE.window?.rootViewController = navController
            SCENE_DELEGATE.window?.makeKeyAndVisible()
       }
       
    private func navigateToEmailVerificationScreen() {
               //MARK: - Go to the VerifyCodeViewController Screen.
        let verifyCodeVC = MyNavigationController.shared.getViewController(identifier: .verifyCodeViewController, storyboardType: .main) as? VerifyCodeViewController
        verifyCodeVC!.isEmailVerification = true
       
               let navController = UINavigationController(rootViewController: verifyCodeVC!)
               SCENE_DELEGATE.window?.rootViewController = navController
               SCENE_DELEGATE.window?.makeKeyAndVisible()
           }
       
       private func navigateToPhoneVerificationScreen() {
          
           let phoneVerifyVC = MyNavigationController.shared.getViewController(identifier: .phoneVerifyVC, storyboardType: .main)
           self.ToastMessage("Verify phone number by OTP")
           let navController = UINavigationController(rootViewController: phoneVerifyVC)
           SCENE_DELEGATE.window?.rootViewController = navController
           SCENE_DELEGATE.window?.makeKeyAndVisible()
       }
 
    private func navigateToDemoAccountCreationScreen() {
        
//        let dashboardVC = MyNavigationController.shared.getViewController(identifier: .dashboardVC, storyboardType: .dashboard)
        let dashboardVC = MyNavigationController.shared.getViewController(identifier: .homeTabbarViewController, storyboardType: .dashboard)
        
        let navController = UINavigationController(rootViewController: dashboardVC)
        SCENE_DELEGATE.window?.rootViewController = navController
        SCENE_DELEGATE.window?.makeKeyAndVisible()
        
    }
   
}
