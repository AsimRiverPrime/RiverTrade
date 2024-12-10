//
//  UserManager.swift
//  RiverPrime
//
//  Created by Ross Rostane on 10/12/2024.
//

import Foundation
class UserManager {
    static let shared = UserManager()
    var currentUser: UserBalance? // Store the decoded User model here
    private init() {}
}
