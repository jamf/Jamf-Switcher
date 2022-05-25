//
//  JamfService.swift
//  Jamf Switcher
//
//  Created by David Norris on 23/05/2022.
//  Copyright © 2022 dataJAR. All rights reserved.
//

import Foundation

public protocol JamfService {
    func findAllPolicies(jamfServerURL: String, apiKey: String, token: String, completion: @escaping(Result<Policies, JamfError>) -> Void)
    func findPolicyById(policyId: Int, jamfServerURL: String, apiKey: String, token: String, completion: @escaping(Result<PolicyResponse, JamfError>) -> Void)
    func flushMatchingPolicies(jamfServerURL: String, apiKey: String, id: Int, token: String, completion: @escaping(Result<JamfResponse, JamfError>) -> Void)
    func createAuthToken(jamfServerURL: String, apiKey: String, completion: @escaping(Result<AuthToken, JamfError>) -> Void)
}
