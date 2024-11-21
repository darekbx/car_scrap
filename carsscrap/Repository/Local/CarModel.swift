//
//  CarModel.swift
//  carsscrap
//
//  Created by Dariusz Baranczuk on 19/11/2024.
//

import Foundation
import SwiftData

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
}
