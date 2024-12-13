//
//  ApiResponseCache.swift
//  RiverPrime
//
//  Created by Ross Rostane on 13/12/2024.
//

import Foundation
import CoreData
import UIKit

//1. Set Up CoreData
//Open your project in Xcode.
//
//Add a CoreData model:
//
//Go to File > New > File > Data Model.
//Create an entity (e.g., CachedData) with attributes matching your API response (e.g., id, name, value).
//Example attributes:
//
//id (String)
//name (String)
//value (String)

class ApiResponseCache {
    let context = CoreDataManager.shared.persistentContainer.viewContext
       
       // Fetch data from CoreData or API
   /*    func fetchData(forceUpdate: Bool = false, completion: @escaping (Result<[/*CachedData*/], Error>) -> Void) {
           if !forceUpdate {
               // Fetch from CoreData
               let cachedData = fetchCachedData()
               if !cachedData.isEmpty {
                   print("Using cached data")
                   completion(.success(cachedData))
                   return
               }
           }
           
           // Fetch from API
           let url = URL(string: "https://api.example.com/data")!
           let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
               if let error = error {
                   completion(.failure(error))
                   return
               }
               
               guard let data = data,
                     let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
                   completion(.failure(NSError(domain: "InvalidData", code: 0, userInfo: nil)))
                   return
               }
               
               // Save to CoreData
               self?.saveToCoreData(jsonArray)
               
               // Return cached data
               completion(.success(self?.fetchCachedData() ?? []))
           }
           task.resume()
       }
       
       // Fetch cached data
       private func fetchCachedData() -> [CachedData] {
           let fetchRequest = CachedData.fetchRequest()
           do {
               return try context.fetch(fetchRequest)
           } catch {
               print("Failed to fetch cached data: \(error)")
               return []
           }
       }
       
       // Save API response to CoreData
       private func saveToCoreData(_ data: [[String: Any]]) {
           // Clear existing data
           clearCachedData()
           
           // Insert new data
           for item in data {
               let cachedData = CachedData(context: context)
               cachedData.id = item["id"] as? String
               cachedData.name = item["name"] as? String
               cachedData.value = item["value"] as? String
           }
           
           // Save context
           CoreDataManager.shared.saveContext()
       }
       
       // Clear cached data
       private func clearCachedData() {
           let fetchRequest = CachedData.fetchRequest()
           let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
           
           do {
               try context.execute(deleteRequest)
               CoreDataManager.shared.saveContext()
           } catch {
               print("Failed to clear cached data: \(error)")
           }
       }
    */
    //How to Use the Service
    //    let apiService = ApiResponseCache()
    
    // Fetch data (use cache if available)
    //    apiService.fetchData { result in
    //        switch result {
    //        case .success(let data):
    //            print("Data: \(data)")
    //        case .failure(let error):
    //            print("Error: \(error)")
    //        }
    //    }
    
    // Force update from API
    //    apiService.fetchData(forceUpdate: true) { result in
    //        switch result {
    //        case .success(let data):
    //            print("Updated Data: \(data)")
    //        case .failure(let error):
    //            print("Error: \(error)")
    //        }
    //    }
}


class CoreDataManager {
    static let shared = CoreDataManager()
    private init() {}
    
    // Reference to Persistent Container
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "YourModelName") // Replace with your .xcdatamodeld file name
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load CoreData stack: \(error)")
            }
        }
        return container
    }()
    
    // Save Context
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error)")
            }
        }
    }
}
