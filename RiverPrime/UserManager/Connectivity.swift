//
//  Connectivity.swift
//  RiverPrime
//
//  Created by Ross Rostane on 22/01/2025.
//

import Foundation
import Network

class Connectivity {
    static let shared = Connectivity()
    private var monitor: NWPathMonitor
    private var isMonitoring = false
    
    private init() {
        self.monitor = NWPathMonitor()
    }
    
    var isConnected: Bool {
        return monitor.currentPath.status == .satisfied
    }
    
    func startMonitoring() {
        guard !isMonitoring else { return }
        
        let queue = DispatchQueue.global(qos: .background)
        monitor.start(queue: queue)
        isMonitoring = true
        
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                if path.status == .satisfied {
                    print("Internet Connection: Available")
                    NotificationCenter.default.post(name: .connectionRestored, object: nil)
                } else {
                    print("Internet Connection: Unavailable")
                    NotificationCenter.default.post(name: .connectionLost, object: nil)
                }
            }
        }
    }
    
    func stopMonitoring() {
        guard isMonitoring else { return }
        monitor.cancel()
        isMonitoring = false
    }
}
