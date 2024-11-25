//
//  ChartView.swift
//  carsscrap
//
//  Created by Dariusz Baranczuk on 19/11/2024.
//

import Foundation
import SwiftUI
import SwiftData
import Charts

struct ChartView: View {
    
    @State private var carsByYears: [Int: [CarModel]] = [:]
    
    @State private var minPrice = 0
    @State private var maxPrice = 0
    
    @State private var yearsFilter: [Int] = []
    @State private var selectedYear = 0
    
    @State private var enginePowers: [Int] = []
    @State private var selectedEnginePower = 0
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                YearsFilter(selectedYear: $selectedYear, years: yearsFilter).padding(.leading, 16)
                EnginePowerFilter(selectedEnginePower: $selectedEnginePower, enginePowers: enginePowers).padding(.leading, 8)
            }
            let maxCount = carsByYears.values.map({ $0.filter { selectedEnginePower == 0 || $0.enginePower == selectedEnginePower }.count }).max() ?? 1
            Chart(Array(carsByYears.sorted { $0.key < $1.key }), id: \.key) { element in
                
                let year: Int = element.key
                let cars: [CarModel] = element.value
                let filteredCard = cars.filter { selectedEnginePower == 0 || $0.enginePower == selectedEnginePower }
                let scale: Double = Double(cars.count) / Double(maxCount)
                
                ForEach(Array(filteredCard.enumerated()), id: \.1) { index, entry in
                    let doubleIndex: Double = Double(index) / scale
                    LineMark(
                        x: .value("index", doubleIndex),
                        y: .value("price", entry.price),
                        series: .value("year", year)
                    )
                    .symbol(.circle)
                    .interpolationMethod(.catmullRom)
                    .lineStyle(StrokeStyle(lineWidth: 1))
                }
                .foregroundStyle(by: .value("year", String(year)))
                .opacity((selectedYear == 0 || year == selectedYear) ? 1.0 : 0.2)
            }
            .chartXAxis(.hidden)
            .chartYAxis {
                AxisMarks(values: .automatic(desiredCount: 10))
            }
        }
        .task {
            fetchData()
        }
    }
    
    private func fetchData() {
        Task {
            let localStore = LocalStore(modelContainer: modelContext.container)
            carsByYears = await localStore.fetchCarsByYears()
            yearsFilter = await localStore.fetchYears()
            enginePowers = await localStore.fetchEnginePowers()
            
            // 0 means All years
            yearsFilter.insert(0, at: 0)
            
            // 0 means All engine powers
            enginePowers.insert(0, at: 0)
        }
    }
}
