//
//  AccommodationResponse.swift
//  AdaptPath
//
//  Created by Justin Biggs on 6/21/26.
//

import Foundation

import SwiftUI

// MARK: - Models
struct AccommodationResponse: Codable {
    let success: Bool
    let accommodations: [[AnyCodable]]
    let error: String?
}

enum AnyCodable: Codable {
    case string(String)
    case double(Double)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        } else if let doubleValue = try? container.decode(Double.self) {
            self = .double(doubleValue)
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unable to decode value"
            )
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value):
            try container.encode(value)
        case .double(let value):
            try container.encode(value)
        }
    }
}
