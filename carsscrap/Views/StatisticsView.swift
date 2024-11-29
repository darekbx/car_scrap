//
//  StatisticsView.swift
//  carsscrap
//
//  Created by Dariusz Baranczuk on 28/11/2024.
//

import SwiftUI
import SwiftUI
import SwiftData

struct StatisticsView: View {
    
    @State private var yearAverages: [[String]] = []
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    var body: some View {
        VStack {
            Text("Average prices")
            
            VStack {
                if yearAverages.count == 2 {
                    let years: [String] = yearAverages[0]
                    let averages: [String] = yearAverages[1]
                    
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
            .padding(.trailing, 16)
            .padding(.leading, 16)
        }
        .task {
            fetchData()
        }
    }
    
    private func fetchData() {
        Task {
            let localStore = LocalStore(modelContainer: modelContext.container)
            let carsByYears = (await localStore.fetchCarsByYears())
            let years = carsByYears.keys.sorted { $0 < $1 }
            
            var averages: [String] = []
            years.forEach { year in
                let yearData = carsByYears[year] ?? []
                let total = yearData.reduce(0, { $0 + $1.price })
                averages.append(String(total / yearData.count))
            }
            
            yearAverages.append(years.map { String($0) })
            yearAverages.append(averages)
        }
    }
}
