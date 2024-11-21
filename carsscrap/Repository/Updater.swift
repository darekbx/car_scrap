//
//  Updater.swift
//  carsscrap
//
//  Created by Dariusz Baranczuk on 19/11/2024.
//

import Foundation

class Updater {
    
    private let dataProvider = DataProvider()
    private let localStore: LocalStore
    
    init(localStore: LocalStore) {
        self.localStore = localStore
    }
    
    func update(progress: (Double) -> Void) async {
        do {
            let nodes = try await dataProvider.fetch { current, total in
                progress(Double(current) * 100.0 / Double(total))
            }
        
            for node in nodes {
                try await localStore.add(node: node)
            }
            
            try await localStore.commit()

        } catch {
            print("fetch error \(error)")
        }
    }
}
