//
//  Structures.swift
//  Jamf Switcher
//
//  Copyright © 2020 dataJAR. All rights reserved.
//

import Foundation

struct JSS {
    var name: String
    var url: String
}

struct Policies: Codable {
    let policies: [Policy]
}

struct Policy: Codable {
    let id: Int
    let name: String
}
