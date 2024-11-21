//
//  LocalStore.swift
//  carsscrap
//
//  Created by Dariusz Baranczuk on 19/11/2024.
//

import Foundation
import SwiftData

@ModelActor
actor LocalStore {
    
    func deleteAll() async {
        do {
            let items = try modelContext.fetch(FetchDescriptor<CarModel>())
            items.forEach { model in
                modelContext.delete(model)
            }
            try modelContext.save()
        } catch {
            print("Failed to delete: \(error)")
        }
    }
    
    func fetch() async -> [CarModel] {
        do {
            return try modelContext.fetch(FetchDescriptor<CarModel>())
        } catch {
            print("Failed to fetch: \(error)")
            return []
        }
    }
    
    func add(node: Node) async throws {
        let fuelType = readValueParameter(parameters: node.parameters, key: "fuel_type") ?? ""
        let gearbox = readValueParameter(parameters: node.parameters, key: "gearbox") ?? ""
        let enginePower = Int(readValueParameter(parameters: node.parameters, key: "engine_power") ?? "0") ?? 0
        let year = Int(readValueParameter(parameters: node.parameters, key: "year") ?? "0") ?? 0
        let countryOrigin = readDisplayValueParameter(parameters: node.parameters, key: "country_origin") ?? ""
        let mileage = Int(readValueParameter(parameters: node.parameters, key: "mileage") ?? "0") ?? 0
        
        let carModel = CarModel(
            externalId: node.id,
            createdAt: node.createdAt,
            url: node.url,
            price: node.price.amount.units,
            currency: node.price.amount.currencyCode,
            fuelType: fuelType,
            gearbox: gearbox,
            enginePower: enginePower,
            year: year,
            countryOrigin: countryOrigin,
            mileage: mileage
        )
        
        modelContext.insert(carModel)
    }
    
    func commit() throws {
        try modelContext.save()
    }
    
    private func readValueParameter(parameters: [Parameter], key: String) -> String? {
        parameters.first { $0.key == key }?.value
    }
    
    private func readDisplayValueParameter(parameters: [Parameter], key: String) -> String? {
        parameters.first { $0.key == key }?.displayValue
    }
}
