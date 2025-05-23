//
//  Fav_SymbolData+CoreDataProperties.swift
//  RiverPrime
//
//  Created by Ross Rostane on 23/05/2025.
//
//

import Foundation
import CoreData


extension Fav_SymbolData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Fav_SymbolData> {
        return NSFetchRequest<Fav_SymbolData>(entityName: "Fav_SymbolData")
    }

    @NSManaged public var is_mobile_favorite: Bool
    @NSManaged public var yesterday_close: String?
    @NSManaged public var mobile_available: String?
    @NSManaged public var spreadSize: String?
    @NSManaged public var swapShort: String?
    @NSManaged public var swapLong: String?
    @NSManaged public var stopsLevel: String?
    @NSManaged public var digits: String?
    @NSManaged public var sector: String?
    @NSManaged public var displayName: String?
    @NSManaged public var contractSize: String?
    @NSManaged public var volumeStep: String?
    @NSManaged public var volumeMax: String?
    @NSManaged public var volumeMin: String?
    @NSManaged public var icon_url: String?
    @NSManaged public var desc: String?
    @NSManaged public var name: String?
    @NSManaged public var id: String?

}

extension Fav_SymbolData : Identifiable {

}
