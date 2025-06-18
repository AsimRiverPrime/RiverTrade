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
    
//    func getSymbolData() -> [SymbolData]?
    
    var symbolData: [SymbolData]? { get set }
    
    var filteredSymbolData: [SymbolData]? { get set }
    
    //MARK: - isRealAccountInitFlowComplete
    var isRealAccountInitFlowComplete: Bool? { get set }
    
    var crmCredentials: CrmCredentialsModel? { get set }
    
    
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
    
    //MARK: - isRealAccountInitFlowComplete
    let kisRealAccountInitFlowComplete = "kisRealAccountInitFlowComplete"
    var isRealAccountInitFlowComplete: Bool? {
        
        set {
            UserDefaults.standard.setValue(newValue, forKey: kisRealAccountInitFlowComplete)
        }
        get {
            if let value = UserDefaults.standard.value(forKey: kisRealAccountInitFlowComplete) as? Bool {
                return value
            }
            return nil
        }
        
    }
    
    //MARK: - SymbolData
    var kSymbolData = "kSymbolData"
    var symbolData: [SymbolData]?
    {
        get
        {
            guard let data = UserDefaults.standard.data(forKey: kSymbolData) else { return nil }
            return (try? JSONDecoder().decode([SymbolData].self, from: data)) ?? nil
        }
        set
        {
            guard let data = try? JSONEncoder().encode(newValue) else { return }
            UserDefaults.standard.set(data, forKey: kSymbolData)
        }
    }
    
    //MARK: - FilteredSymbolData
    var kFilteredSymbolData = "kFilteredSymbolData"
    var filteredSymbolData: [SymbolData]?
    {
        get
        {
            guard let data = UserDefaults.standard.data(forKey: kFilteredSymbolData) else { return nil }
            return (try? JSONDecoder().decode([SymbolData].self, from: data)) ?? nil
        }
        set
        {
            guard let data = try? JSONEncoder().encode(newValue) else { return }
            UserDefaults.standard.set(data, forKey: kFilteredSymbolData)
        }
    }

    var kCrmCredentialsKey = "kCrmCredentialsKey"
        var crmCredentials: CrmCredentialsModel? {
            get {
                guard let data = UserDefaults.standard.data(forKey: kCrmCredentialsKey) else { return nil }
                return try? JSONDecoder().decode(CrmCredentialsModel.self, from: data)
            }
            set {
                guard let data = try? JSONEncoder().encode(newValue) else { return }
                UserDefaults.standard.set(data, forKey: kCrmCredentialsKey)
            }
        }
}
