//
//  JamfLogic.swift
//  Jamf Switcher
//
//  Created by David Norris on 23/05/2022.
//  Copyright © 2022 dataJAR. All rights reserved.
//

import Foundation

public class JamfLogic {
    
    public let jamfService: JamfService
    
    
    public init(jamfService: JamfService = JamfAPI.shared) {
        self.jamfService = jamfService
    }
    
    public func findAllPolicies(jamfServerURL: String, apiKey: String, token: String, completion: @escaping (Result<Policies, JamfError>) -> Void) {
     
        self.jamfService.findAllPolicies(jamfServerURL: jamfServerURL, apiKey: apiKey, token: token) { result in
            
            switch result {
            case .success(let policies):
                completion(.success(policies))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func findPolicyById(policyId: Int, jamfServerURL: String, apiKey: String, token: String, completion: @escaping (Result<PolicyResponse, JamfError>) -> Void) {
     
        self.jamfService.findPolicyById(policyId: policyId, jamfServerURL: jamfServerURL, apiKey: apiKey, token: token) { result in
            
            switch result {
            case .success(let policy):
                completion(.success(policy))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func flushMatchingPolicies(jamfServerURL: String, apiKey: String, id: Int, token: String, completion: @escaping (Result<JamfResponse, JamfError>) -> Void) {
     
        self.jamfService.flushMatchingPolicies(jamfServerURL: jamfServerURL, apiKey: apiKey, id: id, token: token) { result in
            
            switch result {
            case .success(let policies):
                completion(.success(policies))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func createAuthToken(jamfServerURL: String, apiKey: String, completion: @escaping (Result<AuthToken, JamfError>) -> Void) {
        
        self.jamfService.createAuthToken(jamfServerURL: jamfServerURL, apiKey: apiKey) { result in
            
            switch result {
            case .success(let policies):
                completion(.success(policies))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
