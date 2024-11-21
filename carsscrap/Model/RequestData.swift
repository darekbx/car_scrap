//
//  RequestData.swift
//  carsscrap
//
//  Created by Dariusz Baranczuk on 19/11/2024.
//

import Foundation

struct RequestData: Codable {
    let operationName: String
    let query: String
    var variables: Variables
}

struct Variables: Codable {
    var after: String?
    var click2BuyExperimentId: String
    var click2BuyExperimentVariant: String
    var experiments: [Experiment]
    var filters: [Filter]
    var includeCepik: Bool
    var includeClick2Buy: Bool
    var includeFiltersCounters: Bool
    var includeNewPromotedAds: Bool
    var includePriceEvaluation: Bool
    var includePromotedAds: Bool
    var includeRatings: Bool
    var includeSortOptions: Bool
    var includeSuggestedFilters: Bool
    var maxAge: Int
    var page: Int
    var parameters: [String]
    var promotedInput: [String: String]
    var searchTerms: String?
}

struct Experiment: Codable {
    let key: String
    let variant: String
}

struct Filter: Codable {
    let name: String
    let value: String
}
