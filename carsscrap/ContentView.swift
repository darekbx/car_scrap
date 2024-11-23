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
        case List, Chart
    }
    
    @Environment(\.modelContext) private var modelContext
    
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
    
    fileprivate func MenuContainer() -> List<Never, TupleView<(some View, some View)>> {
        return List {
            HStack {
                Image(systemName: "list.bullet")
                    .foregroundColor(.gray)
                    .frame(width: 24)
                Text("List")
                    .font(.headline)
            }
            .onTapGesture {
                destination = Destination.List
            }
            HStack {
                Image(systemName: "chart.bar")
                    .foregroundColor(.gray)
                    .frame(width: 24)
                Text("Chart")
                    .font(.headline)
            }
            .onTapGesture {
                destination = Destination.Chart
            }
        }
    }
    
    fileprivate func DetailContainer() -> ZStack<some View> {
        return ZStack(alignment: .center) {
            if inProgres {
                VStack(alignment: .center) {
                    Text("Updating...")
                    ProgressView(value: progress, total: 100)
                        .padding(.leading, 64)
                        .padding(.trailing, 64)
                }
            } else {
                if destination == Destination.List {
                    CarsListView(modelContext: modelContext)
                } else if destination == Destination.Chart {
                    ChartView(modelContext: modelContext)
                }
            }
        }
    }
    
    private func deleteAll() {
        Task {
            let localStore = LocalStore(modelContainer: modelContext.container)
            await localStore.deleteAll()
        }
    }
    
    private func update() {
        inProgres = true
        Task {
            defer { inProgres = false }
            let localStore = LocalStore(modelContainer: modelContext.container)
            await Updater(localStore: localStore)
                .update { progress in
                    self.progress = progress
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: CarModel.self, inMemory: true)
}
