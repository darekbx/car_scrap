//
//  StatisticsView.swift
//  carsscrap
//
//  Created by Dariusz Baranczuk on 28/11/2024.
//

import SwiftUI

struct StatisticsView: View {
    
    var body: some View {
        Text("hello")
            .task {
               await FirebaseProvider().count()
            }
    }
}
