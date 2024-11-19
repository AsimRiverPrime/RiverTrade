//
//  TransactionCellVM.swift
//  RiverPrime
//
//  Created by Ross Rostane on 04/10/2024.
//

import Foundation
import SDWebImage

class TransactionCellVM {
    
    func loadImage(imageUrl: URL?, completion: @escaping (UIImage?) -> Void) {
        // Use SDWebImage to load the image
        UIImageView().sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "photo.circle")) { image, error, cacheType, url in
            completion(image ?? UIImage(named: "photo.circle"))
        }
    }
    
}

extension TransactionCellVM {
    
    func getSavedSymbols() -> [SymbolData]? {
        let savedSymbolsKey = "savedSymbolsKey"
        if let savedSymbols = UserDefaults.standard.data(forKey: savedSymbolsKey) {
            let decoder = JSONDecoder()
            return try? decoder.decode([SymbolData].self, from: savedSymbols)
        }
        return nil
    }
    
//    func getSavedSymbolsDictionary() -> [String: SymbolData]? {
//        let savedSymbolsKey = "savedSymbolsKey"
//        if let savedSymbolsData = UserDefaults.standard.data(forKey: savedSymbolsKey) {
//            let decoder = JSONDecoder()
//            if let savedSymbols = try? decoder.decode([SymbolData].self, from: savedSymbolsData) {
//                // Create a dictionary mapping names to SymbolData
//                return Dictionary(uniqueKeysWithValues: savedSymbols.map { ($0.name, $0) })
//            }
//        }
//        return nil
//    }
    
    func getSavedSymbolsDictionary() -> [String: SymbolData]? {
        let savedSymbolsKey = "savedSymbolsKey"
        guard let savedSymbolsData = UserDefaults.standard.data(forKey: savedSymbolsKey) else {
            return nil
        }
        
        let decoder = JSONDecoder()
        if let savedSymbols = try? decoder.decode([SymbolData].self, from: savedSymbolsData) {
            // Use a dictionary to handle duplicates manually
            var uniqueSymbols: [String: SymbolData] = [:]
            for symbol in savedSymbols {
                uniqueSymbols[symbol.name] = symbol // Last occurrence of duplicate overwrites
            }
            
//            for symbol in savedSymbols {
//                if let existingSymbol = uniqueSymbols[symbol.name] {
//                    // Add custom duplicate handling logic here, e.g., based on a property like timestamp
//                    if symbol.name > existingSymbol.name {
//                        uniqueSymbols[symbol.name] = symbol
//                    }
//                } else {
//                    uniqueSymbols[symbol.name] = symbol
//                }
//            }
            
            return uniqueSymbols
        }
        
        return nil
    }

    
}
