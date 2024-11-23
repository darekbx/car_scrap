//
//  YearsFilter.swift
//  carsscrap
//
//  Created by Dariusz Baranczuk on 23/11/2024.
//

import SwiftUI

struct YearsFilter: View {
    
    @Binding var selectedYear: Int
    var years: [Int]
    
    var body: some View {
        return Picker("Year", selection: $selectedYear) {
            ForEach(Array(years), id: \.self) { year in
                if year == 0 {
                    Text("All years")
                } else {
                    Text(String(year))
                }
            }
        }
        .padding(.top, 4)
        .frame(width: 140)
    }
}
