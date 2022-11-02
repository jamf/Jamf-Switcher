//
//  Constants.swift
//  Jamf Switcher
//
//  Created by David Norris on 23/05/2022.
//  Copyright © 2022 dataJAR. All rights reserved.
//

import Foundation

public class CommonUtils {
    
    public static let jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        return jsonDecoder
    }()
}

public enum jsonError: Error {
    
    case invalidEndpoint
    case noData
    case dataCorrupted
    case keyNotFound
    case valueNotFound
    case typeMisMatch
    case unknownError
    case noHostFound
}
