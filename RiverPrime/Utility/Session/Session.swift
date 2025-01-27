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
    
//    func getSymbolData() -> [SymbolData]? {
//        let userData = UserDefaults.standard.data(forKey: "symbolData")
//        let decoder = JSONDecoder()
//
//        do {
//            let result = try decoder.decode([SymbolData].self, from: userData ?? Data())
//            return result
//        } catch {
//            let result = [SymbolData]()
//            return result
//        }
//
//    }
    
}

//func saveSymbolData(_ symbolData: [SymbolData]) {
//    guard let data = try? JSONEncoder().encode(symbolData) else { return }
//    UserDefaults.standard.set(data, forKey: "symbolData")
//}
//
//func loadSymbolData() -> [SymbolData] {
//    guard
//        let data = UserDefaults.standard.data(forKey: "symbolData"),
//        let symbolData = try? JSONDecoder().decode([SymbolData].self, from: data)
//    else { return [] }
//    return symbolData
//}
