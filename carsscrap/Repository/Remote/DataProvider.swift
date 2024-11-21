//
//  DataProvider.swift
//  carsscrap
//
//  Created by Dariusz Baranczuk on 18/11/2024.
//

import Foundation

class DataProvider {
    
    func fetch(progress: (Int, Int) -> Void) async throws -> [Node] {
        
        var nodes: [Node] = []
        var page = 1
        
        guard var request = prepareRequest() else { return [] }
        
        while true {
            guard let requestData = prepareRequestData(page: page) else { return [] }
            request.httpBody = requestData
            
            let (data, _) = try await URLSession.shared.data(for: request)
            let root = try JSONDecoder().decode(Root.self, from: data)
            let advertSearch = root.data.advertSearch
            nodes.append(contentsOf: advertSearch.edges.map { $0.node })
            
            let currentOffset = advertSearch.pageInfo.currentOffset
            let pageSize = advertSearch.pageInfo.pageSize
            
            print("Fetched \(currentOffset) of \(advertSearch.totalCount), page \(page)")
            
            page += 1
            progress(currentOffset, advertSearch.totalCount)
            if currentOffset + pageSize > advertSearch.totalCount {
                break
            }
        }
        
        return nodes
    }
    
    private func prepareRequest() -> URLRequest? {
        guard let url = URL(string: ENDPOINT) else {
            print("Invalid url!")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        for (key, value) in HEADERS {
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        return request
    }
    
    private func prepareRequestData(page: Int) -> Data? {
        guard let fileURL = Bundle.main.url(forResource: "request", withExtension: "json") else {
            print("File not found!")
            return nil
        }
        
        guard let jsonData = try? Data(contentsOf: fileURL) else {
            print("Failed to read json!")
            return nil
        }
        
        var requestData: RequestData
        do {
            requestData = try JSONDecoder().decode(RequestData.self, from: jsonData)
        } catch {
            print("Failed to decode JSON: \(error)")
            return nil
        }
        
        requestData.variables.page = page
        
        do  {
            return try JSONEncoder().encode(requestData)
        } catch {
            print("Failed to encode JSON: \(error)")
            return nil
        }
    }
    
    private let HEADERS: [String:String] = [
        "Content-Type": "application/json",
        "Accept-Encoding": "gzip, deflate, br, zstd",
        "Accept-Language": "en-US,en;q=0.5",
        "Accept": "application/graphql-response+json, application/graphql+json, application/json, text/event-stream, multipart/mixed",
        "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:132.0) Gecko/20100101 Firefox/132.0"
    ]
    
    private let ENDPOINT = "https://www.otomoto.pl/graphql"
}
