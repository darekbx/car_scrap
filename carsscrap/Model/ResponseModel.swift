//
//  ResponseModel.swift
//  carsscrap
//
//  Created by Dariusz Baranczuk on 19/11/2024.
//

import Foundation

// MARK: - Root structure
struct Root: Codable {
    let data: DataClass
}

// MARK: - Data class containing advert search
struct DataClass: Codable {
    let advertSearch: AdvertSearch
}

// MARK: - Advert search containing edges
struct AdvertSearch: Codable {
    let edges: [Edge]
    let totalCount: Int
    let pageInfo: PageInfo
}

// MARK: - Data class containing page info
struct PageInfo: Codable {
    let currentOffset: Int
    let pageSize: Int
}

// MARK: - Edge containing node with car details
struct Edge: Codable {
    let node: Node
}

// MARK: - Node with details of the car
struct Node: Codable {
    let createdAt: String
    let id: String
    let parameters: [Parameter]
    let price: Price
    let url: String
}

// MARK: - Parameters for car details
struct Parameter: Codable {
    let key: String
    let value: String
    let displayValue: String
}

// MARK: - Price structure
struct Price: Codable {
    let amount: Amount
}

// MARK: - Amount structure
struct Amount: Codable {
    let currencyCode: String
    let units: Int
}
