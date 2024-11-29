//
//  ContentView.swift
//  carsscrap
//
//  Created by Dariusz Baranczuk on 18/11/2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    enum Destination {
        case List, Chart, Statistics
    }
    
    @Environment(\.modelContext) private var modelContext
    
    @StateObject private var firebaseProvider = FirebaseProvider()
    @State var destination: Destination = Destination.List
    @State var inProgres = false
    @State var progress = 0.0
    
    var body: some View {
        NavigationSplitView {
            MenuContainer()
                .navigationSplitViewColumnWidth(min: 180, ideal: 200)
                .toolbar {
                    /*
                    ToolbarItem {
                        Button(action: deleteAll) {
                            Label("Delete", systemImage: "clear")
                        }
                    }
                    */
                    ToolbarItem {
                        Button(action: update) {
                            Label("Sync", systemImage: "icloud.and.arrow.down")
                        }
                    }
                }
        } detail: {
            DetailContainer()
        }
        .navigationTitle("Cars Scrap")
    }
    
    fileprivate func MenuContainer() -> some View {
        return List {
            HStack {
                Image(systemName: "list.bullet")
                    .foregroundColor(destination == Destination.List ? .orange : .gray)
                    .frame(width: 24)
                Text("List")
                    .font(.headline)
            }
            .onTapGesture {
                destination = Destination.List
            }
            HStack {
                Image(systemName: "chart.bar")
                    .foregroundColor(destination == Destination.Chart ? .orange : .gray)
                    .frame(width: 24)
                Text("Chart")
                    .font(.headline)
            }
            .onTapGesture {
                destination = Destination.Chart
            }
            HStack {
                Image(systemName: "chart.pie")
                    .foregroundColor(destination == Destination.Statistics ? .orange : .gray)
                    .frame(width: 24)
                Text("Statistics")
                    .font(.headline)
            }
            .onTapGesture {
                destination = Destination.Statistics
            }
        }
    }
    
    fileprivate func DetailContainer() -> ZStack<some View> {
        return ZStack(alignment: .center) {
            if inProgres {
                VStack(alignment: .center) {
                    Text("Updating...")
                    ProgressView()
                        .padding(.leading, 64)
                        .padding(.trailing, 64)
                }
            } else {
                if destination == Destination.List {
                    CarsListView(modelContext: modelContext)
                } else if destination == Destination.Chart {
                    ChartView(modelContext: modelContext)
                } else if destination == Destination.Statistics {
                    StatisticsView(modelContext: modelContext)
                }
            }
        }
    }
    
    private func update() {
        inProgres = true
        Task {
            defer { inProgres = false }
            let localStore = LocalStore(modelContainer: modelContext.container)
            /*
             Now data is loaded from Firestore
             await Updater(localStore: localStore)
                .update { progress in
                    self.progress = progress
                }
             */
            await localStore.fillDatabase()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: CarModel.self, inMemory: true)
}
