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
    var accountsMT: [AccountModel] = []
//    var crmCredientals: [CrmCredentialsModel] = []
    var userNotFound: (() -> Void)?
    
    func addUser(_ user: UserModel, completion: @escaping (Error?) -> Void) {
        let userRef = db.collection("users").document(user.uid)
        userRef.setData(user.toDictionary(), completion: completion)
    }
    
    func addUserAccountData(uid: String, data: [String: Any], completion: @escaping (Result<Void, Error>) -> Void) {
        // Add a new document in collection "userAccount"
        db.collection("userKYCdata").document(uid).setData(data, merge: true) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func saveAdditionalUserData(userId: String, kyc: String, address: String, dateOfBirth: String, profileStep: Int, name: String, gender: String, phone: String, email: String, emailVerified: Bool, phoneVerified:Bool, isLogin: Bool, pushedToCRM:Bool, nationality: String, residence : String, /*password: String,*/ registrationType: Int) {
        
        db.collection("users").document(userId).setData([
            "KycStatus" : kyc,
            "address": address,
            "dateOfBirth": dateOfBirth,
            "email":email,
            "emailVerified": emailVerified,
            
            "fullName": name,
            "gender" : gender,
            "uid": userId,
            "isLogin": isLogin,
            "nationality": nationality,
            
            "phone": phone,
            "phoneVerified": phoneVerified,
            "profileStep" : profileStep,
            "pushedToCRM": pushedToCRM,
            "registrationType": registrationType,
            "residence": residence,
        ]) { error in
            if let error = error {
                print("Error saving user data: \(error.localizedDescription)")
            } else {
                print("Additional User data is saved successfully.")
            }
        }
        fetchUserData(userId: userId)
    }
    
    func fetchUserData(userId: String) {
        UserDefaults.standard.set(userId, forKey: "userID")
        print("fetch user ID is: \(userId)")
        
        let docRef = db.collection("users").document(userId)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                
                if let data = document.data() {
                    
                    print("\n fetch User data is: \(data)")
                    
                    // Define the fields you want to keep
                    let fieldsToKeep = [
                        "KycStatus",
                        "address",
                        "dateOfBirth",
                        "email",
                        "emailVerified",
                        "fullName",
                        "gender",
                        "uid",
                        "isLogin",
                        "nationality",
//                        "phone",
                        "phoneVerified",
                        "profileStep",
                        "pushedToCRM",
                        "registrationType",
                        "residence"
                    ]
                    
                    // Filter data to only include desired fields
                    var filteredData = [String: Any]()
                    for field in fieldsToKeep {
                        if let value = data[field] {
                            filteredData[field] = value
                        }
                    }
                    
                    print("\n Filtered User data: \(filteredData)")
                    
                    // Save the filtered data in UserDefaults
                    UserDefaults.standard.set(filteredData, forKey: "userData")
                }
            } else {
                print("User document does not exist: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    func fetchUserAccountsData(userId: String, completion: @escaping () -> Void) {
        print("\n User ID for fetchUserAccountsData: \(userId)")
        
        let query = db.collection("userAccounts").whereField("userID", isEqualTo: userId)
        
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching user accounts: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                print("No user accounts found for the given userID.: \(userId)")
                GlobalVariable.instance.isAccountCreated = false
                self.userNotFound?()
                return
            }
            
            var userAccountsData = [String: [String: Any]]()
            
            // Define the fields you want to keep
            let fieldsToKeep = [
                "KycStatus",
                "name",
                "currency",
                "userID",
                "groupID",
                "isDefault",
                "isReal",
                "password",
                "groupName",
                "accountNumber"
            ]
            
            for document in documents {
                let documentId = document.documentID
                let data = document.data()
                
                // Filter data to only include desired fields
                var filteredData = [String: Any]()
                for field in fieldsToKeep {
                    if let value = data[field] {
                        filteredData[field] = value
                    }
                }
                
                userAccountsData[documentId] = filteredData
            }
                        
            // Save the filtered data in UserDefaults
            UserDefaults.standard.set(userAccountsData, forKey: "userAccountsData")
            print("\n All User MT Accounts saved: \(userAccountsData)")
            
            // Update accounts
            UserAccountManager.shared.updateAccounts(from: userAccountsData)
            
            // Retrieve and print the default account
            if let defaultAccount = UserAccountManager.shared.getDefaultAccount() {
                print("\n Default user Account in fetchuserAccountFunction : \(defaultAccount)")
                UserDefaults.standard.set(defaultAccount.password, forKey: "password")
               
            }
            
            GlobalVariable.instance.isAccountCreated = !userAccountsData.isEmpty
            completion()
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
                    self.accountsMT.append(account)
                }
            }
            print("accountGroup data:\(self.accountsMT)")
            completion(self.accountsMT)
        }
    }
    
    func handleFaceID(){
        if let data = UserDefaults.standard.dictionary(forKey: "userData") {
            print("\n Handle saved User for navigation to faceID: \(data)")
            navigateToFaceID()
        }
        
    }
    
    func handleUserData() {
        if let data = UserDefaults.standard.dictionary(forKey: "userData") {
            print("\n Handle saved User for navigation : \(data)")
            navigateToDashboardScreen()
            
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
    
    func updatePassword(for accountKey: String, userId: String, newPassword: String, completion: @escaping (Error?) -> Void) {
        print("Updating password for accountKey: \(accountKey), userId: \(userId)")
        
        // Retrieve accounts from UserDefaults
        guard var accountsDict = UserDefaults.standard.dictionary(forKey: "userAccountsData") as? [String: [String: Any]] else {
            print("No accounts found in UserDefaults. Fetching data...")
            fetchUserAccountsData(userId: userId) {
                self.updatePassword(for: accountKey, userId: userId, newPassword: newPassword, completion: completion)
            }
            return
        }
        
        print("accountsDict values: \(accountsDict)")
        
        var updated = false
        
        // Update only the matching account in UserDefaults
        for (key, var accountData) in accountsDict {
            if let accountUserID = accountData["userID"] as? String,
               let accountNumber = accountData["accountNumber"] as? Int,
               accountUserID == userId,
               accountNumber == Int(accountKey) {
                
                accountData["password"] = newPassword
                accountsDict[key] = accountData
                updated = true
                print("✅ Updated password in UserDefaults for accountKey: \(accountKey)")
                break // stop after finding the match
            }
        }
        
        guard updated else {
            print("⚠️ No matching account found for accountKey: \(accountKey), userId: \(userId)")
            completion(nil)
            return
        }
        
        // Save updated accounts back to UserDefaults
        UserDefaults.standard.set(accountsDict, forKey: "userAccountsData")
        UserDefaults.standard.synchronize()
        
        // Update password in Firebase only for the matching account
        let batch = self.db.batch()
        
        for (key, account) in accountsDict {
            if let accountUserID = account["userID"] as? String,
               let accountNumber = account["accountNumber"] as? Int,
               accountUserID == userId,
               accountNumber == Int(accountKey) {
                
                let password = account["password"] as? String ?? "0"
                print("Setting password in Firebase for accountKey \(key): \(password)")
                let docRef = self.db.collection("userAccounts").document(key)
                batch.setData(["password": password], forDocument: docRef, merge: true)
                break // stop after matching
            }
        }
        
        // Commit the batch
        batch.commit { error in
            if let error = error {
                print("❌ Error updating password in Firebase: \(error.localizedDescription)")
                completion(error)
            } else {
                print("✅ Password updated successfully in Firebase")
                self.fetchUserAccountsData(userId: userId) {
                    completion(nil)
                }
            }
        }
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
        
        for (key, account) in accountsDict {
            if var accountData = account as? [String: Any],
               let accountUserID = accountData["userID"] as? String,
               let accountNumber = accountData["accountNumber"] as? Int {
                
                let isMatchingAccount = (accountNumber == Int(accountKey))
                let isMatchingUser = (accountUserID == userId)
                
                print("Key: \(key), accountNumber: \(accountNumber), isMatchingAccount: \(isMatchingAccount), accountUserID: \(accountUserID), isMatchingUser: \(isMatchingUser)")
                
                accountData["isDefault"] = (isMatchingAccount && isMatchingUser) ? true : false
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
                let isDefault = account["isDefault"] as? Bool
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
    
    func navigateToLoginScreen() {
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
    
    private func navigateToDashboardScreen() {
        
        let dashboardVC = MyNavigationController.shared.getViewController(identifier: .homeTabbarViewController, storyboardType: .dashboard)
        
        let navController = UINavigationController(rootViewController: dashboardVC)
        SCENE_DELEGATE.window?.rootViewController = navController
        SCENE_DELEGATE.window?.makeKeyAndVisible()
        
    }
    
    private func navigateToFaceID(){
        let faceidVC = MyNavigationController.shared.getViewController(identifier: .passcodeFaceIDVC, storyboardType: .main)
        
        let navController = UINavigationController(rootViewController: faceidVC)
        SCENE_DELEGATE.window?.rootViewController = navController
        SCENE_DELEGATE.window?.makeKeyAndVisible()
    }
}
