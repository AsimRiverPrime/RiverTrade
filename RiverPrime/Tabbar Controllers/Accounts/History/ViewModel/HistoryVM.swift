//
//  HistoryVM.swift
//  RiverPrime
//
//  Created by abrar ul haq on 14/10/2024.
//

import Foundation

class HistoryVM {
    
    var vm = TradeTypeCellVM()
//    weak var delegate: OPCDelegate?
//    var onCloseSuccess: (() -> Void)?
    
}

extension HistoryVM {
    
    func fetchPositions(fromDate: Int? = nil, toDate: Int? = nil, completion: @escaping ([NewCloseModel]?, Error?) -> Void) {
        
        // Execute the fetch on a background thread
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.vm.OPCApi(index: 2, fromDate: fromDate, toDate: toDate) { _, _, closeData, error in
                print("\n history data is:\n \(closeData) \n")
                // Switch back to the main thread to update the UI
                DispatchQueue.main.async {
                    if let error = error {
                        print("Error fetching positions: \(error)")
                        completion(nil, error)
                        // Handle the error (e.g., show an alert)
                    } else if let orders = closeData {
                      
                        completion(orders, nil)
//                        self?.delegate?.getOPCData(opcType: .close(orders))
                    }
                }
            }
        }
        
    }
    
   
}
