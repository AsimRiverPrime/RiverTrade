//
//  EconomicCalendarModel.swift
//  RiverPrime
//
//  Created by Ross Rostane on 16/12/2024.
//

import Foundation
struct EconomicCalendarModel: Codable {
    let jsonrpc: String
    let id: Int
    let result: Resultss
}

// Result Model
struct Resultss: Codable {
    let success: Bool
    let payload: [Event]
}

// Event Model
struct Event: Codable {
    let calendarId: String
    let date: String
    let country: String
    let category: String
    let event: String
    let reference: String
    let referenceDate: String
    let source: String
    let sourceURL: String
    let actual: String
    let previous: String
    let forecast: String
    let teForecast: String
    let url: String
    let dateSpan: String
    let importance: Int
    let lastUpdate: String
    let revised: String
    let currency: String
    let unit: String
    let ticker: String
    let symbol: String
    
    // CodingKeys for mapping JSON keys to Swift properties
    private enum CodingKeys: String, CodingKey {
        case calendarId = "CalendarId"
        case date = "Date"
        case country = "Country"
        case category = "Category"
        case event = "Event"
        case reference = "Reference"
        case referenceDate = "ReferenceDate"
        case source = "Source"
        case sourceURL = "SourceURL"
        case actual = "Actual"
        case previous = "Previous"
        case forecast = "Forecast"
        case teForecast = "TEForecast"
        case url = "URL"
        case dateSpan = "DateSpan"
        case importance = "Importance"
        case lastUpdate = "LastUpdate"
        case revised = "Revised"
        case currency = "Currency"
        case unit = "Unit"
        case ticker = "Ticker"
        case symbol = "Symbol"
    }
}
