//
//  Session.swift
//  RiverPrime
//
//  Created by Ross Rostane on 17/09/2024.
//

import Foundation

protocol ISession {
    
    //MARK: - IsQR
    var isFaceIDEnabled: Bool? { get set }
    
}

class Session: ISession {
    
    static let instance = Session()
    
    private init() {}
    
    //MARK: - isFaceIDEnabled
    let kisFaceIDEnabled = "isFaceIDEnabled"
    var isFaceIDEnabled: Bool? {
        
        set {
            UserDefaults.standard.setValue(newValue, forKey: kisFaceIDEnabled)
        }
        get {
            if let value = UserDefaults.standard.value(forKey: kisFaceIDEnabled) as? Bool {
                return value
            }
            return nil
        }
        
    }
    
}
