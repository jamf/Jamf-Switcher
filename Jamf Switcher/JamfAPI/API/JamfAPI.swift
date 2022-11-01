//
//  JamfAPI.swift
//  Jamf Switcher
//
//  Created by David Norris on 23/05/2022.
//  Copyright © 2022 dataJAR. All rights reserved.
//

import Foundation

public class JamfAPI: JamfService {

    public static let shared = JamfAPI()
    public let callapi = CallAPI()
    private init() {}

    public func findAllPolicies(jamfServerURL: String, apiKey: String, token: String = "", completion: @escaping(Result<Policies, JamfError>) -> Void) {
        
        guard let url = URL(string: "\(jamfServerURL)/JSSResource/policies") else {
            completion(.failure(JamfError(statusCode: 0, error: .invalidEndpoint)))
            return
           }
        //URL Request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if token.isEmpty {
            request.setValue("Basic \(apiKey)", forHTTPHeaderField: "Authorization")
        } else {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        //MARK:- pass in the URL to loadAndDecode
        callapi.loadAndDecode(request: request,
                           completion: completion)
    }
    
    public func findPolicyById(policyId: Int, jamfServerURL: String, apiKey: String, token: String = "", completion: @escaping(Result<PolicyResponse, JamfError>) -> Void) {
        
        guard let url = URL(string: "\(jamfServerURL)/JSSResource/policies/id/\(policyId)") else {
            completion(.failure(JamfError(statusCode: 0, error: .invalidEndpoint)))
            return
           }
        print(url)
        //URL Request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if token.isEmpty {
            request.setValue("Basic \(apiKey)", forHTTPHeaderField: "Authorization")
        } else {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        //MARK:- pass in the URL to loadAndDecode
        callapi.loadAndDecode(request: request,
                           completion: completion)
    }
    
    public func flushMatchingPolicies(jamfServerURL: String, apiKey: String, id: Int, token: String, completion: @escaping(Result<JamfResponse, JamfError>) -> Void) {
        
        guard let url = URL(string: "\(jamfServerURL)/JSSResource/logflush/policies/id/\(id)/interval/Zero+Days") else {
            completion(.failure(JamfError(statusCode: 0, error: .invalidEndpoint)))
            return
           }
        print(url)
        //URL Request
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        if token.isEmpty {
            request.setValue("Basic \(apiKey)", forHTTPHeaderField: "Authorization")
        } else {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.setValue("application/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/xml; charset=utf-8", forHTTPHeaderField: "Accept")
        
        //MARK:- pass in the URL to loadAndDecode
        callapi.execute(request: request,
                           completion: completion)
    }
    
    public func createAuthToken(jamfServerURL: String, apiKey: String, completion: @escaping(Result<AuthToken, JamfError>) -> Void) {
        
        guard let url = URL(string: "\(jamfServerURL)/api/v1/auth/token") else {
            completion(.failure(JamfError(statusCode: 0, error: .invalidEndpoint)))
            return
           }
        
        //URL Request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Basic \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        //MARK:- pass in the URL to loadAndDecode
        callapi.loadAndDecode(request: request,
                           completion: completion)
    }
    
}
