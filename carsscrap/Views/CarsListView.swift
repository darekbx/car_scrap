//
//  CarsListView.swift
//  carsscrap
//
//  Created by Dariusz Baranczuk on 19/11/2024.
//

import SwiftUI
import SwiftData

struct CarsListView: View {
    
    @State private var cars: [CarModel] = []
    @State private var sortOrder = [KeyPathComparator(\CarModel.price)]
    
    @State private var years: [Int] = []
    @State private var selectedYear = 0
    
    @State private var enginePowers: [Int] = []
    @State private var selectedEnginePower = 0
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    var body: some View {
        // https://developer.apple.com/documentation/SwiftUI/OutlineGroup
        VStack(alignment: .leading) {
            HStack {
                YearsFilter(selectedYear: $selectedYear, years: years)
                    .padding(.leading, 16)
                EnginePowerFilter(selectedEnginePower: $selectedEnginePower, enginePowers: enginePowers)
                    .padding(.leading, 8)
            }
            Table(cars
                .filter { selectedYear == 0 || $0.year == selectedYear }
                .filter { selectedEnginePower == 0 || $0.enginePower == selectedEnginePower }, sortOrder: $sortOrder) {
                    TableColumn("Created At", value: \.createdAt).width(150)
                    TableColumn("Year", value: \.year) { Text(String($0.year)) }.width(50)
                    TableColumn("Mileage", value: \.mileage) { Text("\($0.mileage)") }.width(70).alignment(.trailing)
                    TableColumn("Gearbox", value: \.gearbox).width(70)
                    TableColumn("Country", value: \.countryOrigin).width(100)
                    TableColumn("Price", value: \.price) { Text("\($0.price) \($0.currency)") }.width(80).alignment(.trailing)
                    TableColumn("KM", value: \.enginePower) { Text("\($0.enginePower)") }.width(40).alignment(.trailing)
                    TableColumn("Fuel", value: \.fuelType).width(50)
                    TableColumn(" ", value: \.url) { Link("Link", destination: URL(string: $0.url)!) }.width(50)
                }
                .onChange(of: sortOrder, { oldValue, newValue in
                    cars.sort(using: newValue)
                })
                .task {
                    fetchData()
                }
            
            HStack {
                Text("\(cars.count) items")
                    .padding(.trailing, 8)
                    .padding(.bottom, 6)
            }.frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
    
    private func fetchData() {
        Task {
            let localStore = LocalStore(modelContainer: modelContext.container)
            cars = await localStore.fetch()
            years = await localStore.fetchYears()
            enginePowers = await localStore.fetchEnginePowers()
            
            // 0 means All years
            years.insert(0, at: 0)
            
            // 0 means All engine powers
            enginePowers.insert(0, at: 0)
        }
    }
}
