//
//  Model.swift
//  TZLuxuryTeam2025.07.18
//
//  Created by Валентин on 19.07.2025.
//

import Foundation

struct Stock: Codable, Equatable {
    let symbol: String
    let name: String
    let price: Double
    let change: Double
    let changePercent: Double
    let logo: URL
}
