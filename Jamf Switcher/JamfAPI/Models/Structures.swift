//
//  Structures.swift
//  Jamf Switcher
//
//  Copyright © 2020 dataJAR. All rights reserved.
//

import Foundation

public struct JSS {
    var name: String
    var url: String
}

public struct JamfError: Error {
    let statusCode: Int
    let error: jsonError
}

public struct JamfResponse: Codable{
    let statusCode: Int
}

public struct Policies: Codable {
    let policies: [Policy]
}

public struct Policy: Codable {
    let id: Int
    let name: String
}

public struct AuthToken: Codable {
    let token: String
    let expires: String
}

public struct PolicyResponse: Codable {
    let policy: PolicyDetails
}

public struct PolicyDetails: Codable {
    let general: General
}

public struct General: Codable {
    let id: Int
    let name: String
    let enabled: Bool
}
