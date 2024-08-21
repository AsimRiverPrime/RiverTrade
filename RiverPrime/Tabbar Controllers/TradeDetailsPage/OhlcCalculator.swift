//
//  OhlcCalculator.swift
//  RiverPrime
//
//  Created by Ross Rostane on 21/08/2024.
//

import Foundation

class OhlcCalculator {

    class PriceData {
        var ask: Double
        var bid: Double
        var timestamp: Int64

        init(ask: Double, bid: Double, timestamp: Int64) {
            self.ask = ask
            self.bid = bid
            self.timestamp = timestamp
        }
    }

    class OhlcData: CustomStringConvertible {
        var intervalStart: Int64
        var open: Double
        var high: Double
        var low: Double
        var close: Double

        init(intervalStart: Int64, open: Double, high: Double, low: Double, close: Double) {
            self.intervalStart = intervalStart
            self.open = open
            self.high = high
            self.low = low
            self.close = close
        }

        var description: String {
            return "OHLC [intervalStart=\(intervalStart), open=\(open), high=\(high), low=\(low), close=\(close)]"
        }
    }

    private var priceDataQueue = [PriceData]()
    private let intervalMillis: Int64 = 60 // 1 minute in milliseconds
    private let secondIntervalMillis: Int64 = 1 // 1 second in milliseconds
    private var secondOhlcMap = [Int64: OhlcData]()
    private var latestOhlcData: OhlcData?
    private var minuteOpen: Double = -1
    private var lastMinuteStart: Int64 = -1
    private var previousClose: Double = -1 // Track previous minute's close price

    init() {}

    func update(ask: Double, bid: Double, currentTimestamp: Int64) {
        let roundedMinuteStart = (currentTimestamp / intervalMillis) * intervalMillis
        let secondIntervalStart = (currentTimestamp / secondIntervalMillis) * secondIntervalMillis

        // Check if we are in a new minute
        if roundedMinuteStart != lastMinuteStart {
            // Reset minuteOpen to the previous minute's close price if available
            if previousClose != -1 {
                minuteOpen = previousClose
            } else {
                minuteOpen = Double(bid) // Fallback to current midpoint
            }
            lastMinuteStart = roundedMinuteStart
            previousClose = -1 // Reset previous close after transferring to new open
        }

        priceDataQueue.append(PriceData(ask: ask, bid: bid, timestamp: currentTimestamp))
        processSecondInterval(secondIntervalStart: secondIntervalStart, minuteStart: roundedMinuteStart) // Process on-the-fly
    }

    private func processSecondInterval(secondIntervalStart: Int64, minuteStart: Int64) {
        // Ensure we're processing only within the current minute
        if secondIntervalStart < minuteStart || secondIntervalStart >= minuteStart + intervalMillis {
            return // Ignore data outside the current minute
        }

        var high: Double = Double.leastNormalMagnitude
        var low: Double = Double.greatestFiniteMagnitude
        var close: Double = -1

        while !priceDataQueue.isEmpty {
            let data = priceDataQueue.first!
            let dataTimestamp = data.timestamp
            let dataSecondIntervalStart = (dataTimestamp / secondIntervalMillis) * secondIntervalMillis

            if dataSecondIntervalStart > secondIntervalStart {
                break // Data is outside the current second interval
            }

            priceDataQueue.removeFirst() // Remove processed data

            let midpoint = Double(data.bid)
            high = max(high, midpoint)
            low = min(low, midpoint)
            close = midpoint // Latest midpoint becomes the close value for this interval
        }

        // Only update if we have valid data
        if minuteOpen != -1 {
            secondOhlcMap[secondIntervalStart] = OhlcData(intervalStart: secondIntervalStart, open: minuteOpen, high: high, low: low, close: close)
            updateMinuteOhlc(minuteStart: minuteStart, close: close)  // This recalculates the minute-level OHLC data.
        }
    }

    private func updateMinuteOhlc(minuteStart: Int64, close: Double) {
        var minuteHigh: Double = Double.leastNormalMagnitude
        var minuteLow: Double = Double.greatestFiniteMagnitude
        var minuteClose: Double = -1
        var ohlcUpdated = false

        // Iterate through each second's OHLC data within the current minute
        for (secondIntervalStart, secondOhlc) in secondOhlcMap {
            if (secondIntervalStart / intervalMillis) * intervalMillis != minuteStart {
                continue // Skip second intervals not in the current minute
            }

            minuteHigh = max(minuteHigh, secondOhlc.high)
            minuteLow = min(minuteLow, secondOhlc.low)
            minuteClose = close
            ohlcUpdated = true
        }

        if ohlcUpdated && minuteOpen != -1 {
            latestOhlcData = OhlcData(intervalStart: minuteStart, open: minuteOpen, high: minuteHigh, low: minuteLow, close: minuteClose)
            previousClose = minuteClose // Update previous close for the next minute
        }

        // Remove second-level OHLC data that's outside of the current minute to free memory
        secondOhlcMap = secondOhlcMap.filter { ($0.key / intervalMillis) * intervalMillis == minuteStart }
    }

    func getLatestOhlcData() -> OhlcData? {
        return latestOhlcData
    }
}
