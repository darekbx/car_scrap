//
//  EnginePowerFilter.swift
//  carsscrap
//
//  Created by Dariusz Baranczuk on 23/11/2024.
//

import SwiftUI

struct EnginePowerFilter: View {
    
    @Binding var selectedEnginePower: Int
    var enginePowers: [Int]
    
    var body: some View {
        return Picker("Engine power", selection: $selectedEnginePower) {
            ForEach(Array(enginePowers), id: \.self) { power in
                if power == 0 {
                    Text("All engine powers")
                } else {
                    Text(String(power))
                }
            }
        }
        .padding(.top, 4)
        .frame(width: 200)
    }
}
