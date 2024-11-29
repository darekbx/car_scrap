//
//  CarModel.swift
//  carsscrap
//
//  Created by Dariusz Baranczuk on 19/11/2024.
//

import Foundation
import SwiftData
import FirebaseFirestore

@Model
final class CarModel: Identifiable {
    @Attribute(.unique) var id: String = UUID().uuidString
    @Attribute(.unique) var externalId: String
    @Attribute var createdAt: String
    @Attribute var url: String
    @Attribute var price: Int
    @Attribute var currency: String
    @Attribute var fuelType: String
    @Attribute var gearbox: String
    @Attribute var enginePower: Int
    @Attribute var year: Int
    @Attribute var countryOrigin: String
    @Attribute var mileage: Int
    
    init(
        id: String = UUID().uuidString,
        externalId: String,
        createdAt: String,
        url: String,
        price: Int,
        currency: String,
        fuelType: String,
        gearbox: String,
        enginePower: Int,
        year: Int,
        countryOrigin: String,
        mileage: Int
    ) {
        self.id = id
        self.externalId = externalId
        self.createdAt = createdAt
        self.url = url
        self.price = price
        self.currency = currency
        self.fuelType = fuelType
        self.gearbox = gearbox
        self.enginePower = enginePower
        self.year = year
        self.countryOrigin = countryOrigin
        self.mileage = mileage
    }
    
    init?(from document: DocumentSnapshot, formatter: DateFormatter) {
        guard
            let data = document.data(),
            let createdAt = data["createdAt"] as? Timestamp,
            let url = data["url"] as? String,
            let currency = data["currency"] as? String,
            let fuelType = data["fuelType"] as? String,
            let gearbox = data["gearbox"] as? String
        else { return nil }
        
        let date = createdAt.dateValue()
        
        self.externalId = fixStringValue(data["externalId"])
        self.createdAt = formatter.string(from: date)
        self.url = url
        self.price = fixIntValue(data["price"])
        self.currency = currency
        self.fuelType = fuelType
        self.gearbox = gearbox
        self.enginePower = fixIntValue(data["enginePower"])
        self.year = fixIntValue(data["year"])
        self.countryOrigin = fixStringValue(data["countryOrigin"])
        self.mileage = fixIntValue(data["mileage"])
    }
}

fileprivate func fixStringValue(_ value: Any?) -> String {
    if let value = value {
        if let valueAsInt = value as? Int {
            return String(valueAsInt)
        } else if let valueAsString = value as? String {
            return valueAsString
        }
    }
    return ""
}

fileprivate func fixIntValue(_ value: Any?) -> Int {
    if let value = value {
        if let valueAsInt = value as? Int {
            return valueAsInt
        } else if let valueAsString = value as? String {
            return Int(valueAsString) ?? -2
        }
    }
    return -1
}
