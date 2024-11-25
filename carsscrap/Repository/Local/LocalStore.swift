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
            var descriptor = FetchDescriptor<CarModel>()
            descriptor.sortBy = [SortDescriptor(\.createdAt)]
            return try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch: \(error)")
            return []
        }
    }
    
    func fetchCarsByYears() async -> [Int: [CarModel]] {
        do {
            var descriptor = FetchDescriptor<CarModel>()
            descriptor.sortBy = [SortDescriptor(\.createdAt)]
            return Dictionary(grouping: try modelContext.fetch(descriptor), by: { $0.year })
        } catch {
            print("Failed to fetch: \(error)")
            return [:]
        }
    }
    
    func fetchYears() async -> [Int] {
        do {
            var descriptor = FetchDescriptor<CarModel>()
            descriptor.propertiesToFetch = [\.year]
            return Set(try modelContext.fetch(descriptor).map { $0.year }).sorted()
        } catch {
            print("Failed to fetch years: \(error)")
            return []
        }
    }
    
    func fetchEnginePowers() async -> [Int] {
        do {
            var descriptor = FetchDescriptor<CarModel>()
            descriptor.propertiesToFetch = [\.enginePower]
            return Set(try modelContext.fetch(descriptor).map { $0.enginePower }).sorted()
        } catch {
            print("Failed to fetch engine power: \(error)")
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
