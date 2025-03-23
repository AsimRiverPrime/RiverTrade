//
//  NetellerPaymentRequest.swift
//  RiverPrime
//
//  Created by Asim Ali on 22/03/2025.
//
struct NetellerPaymentRequest: Codable {
    let clientId: String
    let amount: Int // Paysafe expects amount in minor units (e.g., 1000 = 10.00)
    let currency: String
    let paymentType: String // Use "NETELLER" for Neteller payments
    let merchantRefNum: String
    let returnLinks: [ReturnLink]
    
    struct ReturnLink: Codable {
        let rel: String
        let href: String
    }
}
