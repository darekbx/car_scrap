//
//  StatisticsView.swift
//  carsscrap
//
//  Created by Dariusz Baranczuk on 28/11/2024.
//

import SwiftUI
import SwiftUI
import SwiftData
import Charts

struct StatisticsView: View {
    
    private let validEnginePowers = [145, 165, 192, 194, 250]
    
    @State private var yearAverages: [[String]] = []
    @State private var histogram: [AveragePriceToYear] = []
    @State private var enginePowerCount: [EnginePowerToYear] = []
    
    @State private var enginePowers: [Int] = []
    @State private var selectedEnginePower = 0
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Text("Average prices")
                EnginePowerFilter(selectedEnginePower: $selectedEnginePower, enginePowers: enginePowers)
                    .padding(.leading, 8)
            }
            .padding()
            
            VStack {
                if yearAverages.count == 2 && !histogram.isEmpty {
                    AveragePrice()
                    Spacer().frame(height: 32)
                    HStack {
                        VStack {
                            Text("Average prices").padding(.bottom, 16)
                            AveragePriceChart()
                        }
                        VStack {
                            Text("Engine power").padding(.bottom, 16)
                            EnginePowerChart()
                        }
                    }
                }
            }
            .padding(.trailing, 16)
            .padding(.leading, 16)
            Spacer()
        }
        .task(id: selectedEnginePower) {
            fetchData()
        }
    }
    
    fileprivate func AveragePrice() -> some View {
        let years: [String] = yearAverages[0]
        let averages: [String] = yearAverages[1]
        return VStack {
            HStack {
                ForEach(years, id: \.self) { year in
                    Text(year)
                        .fontWeight(.bold)
                        .padding(.top, 2)
                        .padding(.bottom, 3)
                        .frame(maxWidth: 100)
                        .background()
                        .cornerRadius(4)
                        .padding(.bottom, 3)
                    Divider().frame(height: 20)
                }
            }
            .padding(.bottom, -6)
            Divider().frame(height: 1)
            HStack {
                ForEach(averages, id: \.self) { average in
                    Text("\(average) PLN")
                        .frame(maxWidth: 100)
                    Divider().frame(height: 20)
                }
            }
        }
    }
    
    fileprivate func AveragePriceChart() -> some View {
        let minYear: Int = histogram.map { $0.year }.min() ?? 0
        let maxyear: Int = histogram.map { $0.year }.max() ?? 0
        return Chart {
            ForEach(histogram) { entry in
                BarMark(
                    x: .value("Average price", entry.year),
                    y: .value("Year", entry.averagePrice)
                )
            }
        }
        .chartXScale(domain: (minYear - 1)...(maxyear + 1))
        .chartXAxis {
            AxisMarks(values: histogram.map { $0.year }) { value in
                AxisGridLine()
                AxisTick()
                if let year = value.as(Int.self) {
                    AxisValueLabel(String(year), centered: false, anchor: .top)
                }
            }
        }
        .chartYAxis {
            AxisMarks(values: .stride(by: 10000))
        }
        .frame(height: 300)
    }
    
    fileprivate func EnginePowerChart() -> some View {
        let years = enginePowerCount.map { $0.year }
        let minYear: Int = enginePowerCount.map { $0.year }.min() ?? 0
        let maxyear: Int = enginePowerCount.map { $0.year }.max() ?? 0
        return Chart {
            ForEach(enginePowerCount) { enginePowersByYear in
                BarMark(
                    x: .value("Year", enginePowersByYear.year),
                    y: .value("Count", enginePowersByYear.count)
                )
                .foregroundStyle(by: .value("Power", enginePowersByYear.enginePower))
            }
        }
        .chartXScale(domain: (minYear - 1)...(maxyear + 1))
        .chartXAxis {
            AxisMarks(values: years) { value in
                AxisGridLine()
                AxisTick()
                if let year = value.as(Int.self) {
                    AxisValueLabel(String(year), centered: false, anchor: .top)
                }
            }
        }
        .frame(height: 300)
    }
    
    private func fetchData() {
        Task {
            let localStore = LocalStore(modelContainer: modelContext.container)
            let carsByYears = (await localStore.fetchCarsByYears())
            let years = carsByYears.keys.sorted { $0 < $1 }
            
            var averageYears: [String] = []
            var averages: [String] = []
            
            histogram.removeAll()
            yearAverages.removeAll()
            enginePowerCount.removeAll()
            
            enginePowers = await localStore.fetchEnginePowers().filter { validEnginePowers.contains($0) }
            // 0 means All engine powers
            enginePowers.insert(0, at: 0)
            
            years.forEach { year in
                let yearData = carsByYears[year] ?? []
                let yearDataSorted = yearData
                    .filter { selectedEnginePower == 0 || $0.enginePower == selectedEnginePower }
                    .sorted { $0.price < $1.price }
                
                if !yearDataSorted.isEmpty {
                    
                    // Remove lowest and highest price from average calculation
                    let normalizedYearData = yearDataSorted
                        .dropFirst()
                        .dropLast()
                    let total = normalizedYearData.reduce(0, { $0 + $1.price })
                    let averagePrice = total / yearDataSorted.count
                    averages.append(String(averagePrice))
                    averageYears.append(String(year))
                    
                    histogram.append(AveragePriceToYear(averagePrice, year))
                    
                    for (enginePower, items) in Dictionary(grouping: yearDataSorted, by: { $0.enginePower }) {
                        let entry = EnginePowerToYear(enginePower: enginePower, count: items.count, year: year)
                        // Limit only to valid engine powers
                        if validEnginePowers.contains(entry.enginePower) {
                            enginePowerCount.append(entry)
                        }
                    }
                }
            }
            
            yearAverages.append(averageYears) // Headers
            yearAverages.append(averages) // Averages
        }
    }
}

class AveragePriceToYear: Identifiable {
    var averagePrice: Int
    var year: Int
    
    init(_ averagePrice: Int, _ year: Int) {
        self.averagePrice = averagePrice
        self.year = year
    }
}

class EnginePowerToYear: Identifiable {
    var enginePower: Int
    var count: Int
    var year: Int
    
    init(enginePower: Int, count: Int, year: Int) {
        self.enginePower = enginePower
        self.count = count
        self.year = year
    }
}
