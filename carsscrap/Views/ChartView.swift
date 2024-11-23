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
    
    @State private var cars: [CarModel] = []
    
    @State private var minPrice = 0
    @State private var maxPrice = 0
    
    @State private var years: [Int] = []
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
                YearsFilter(selectedYear: $selectedYear, years: years)
                    .padding(.leading, 16)
                EnginePowerFilter(selectedEnginePower: $selectedEnginePower, enginePowers: enginePowers)
                    .padding(.leading, 8)
            }
            Chart {
                ForEach(
                    cars
                        .filter { selectedYear == 0 || $0.year == selectedYear }
                        .filter { selectedEnginePower == 0 || $0.enginePower == selectedEnginePower },
                    id: \.self) { entry in
                        LineMark(
                            x: .value("date", entry.id),
                            y: .value("price", entry.price)
                        )
                        .lineStyle(StrokeStyle(lineWidth: 1))
                        .foregroundStyle(Color.green)
                    }
            }
            .chartXAxis(.hidden)
        }
        .task {
            fetchData()
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
