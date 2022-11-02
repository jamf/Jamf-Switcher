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
    
    public func createAuthToken(jamfServerURL: String, apiKey: String, completion: @escaping (Result<AuthToken, JamfError>) -> Void) {
        
        self.jamfService.createAuthToken(jamfServerURL: jamfServerURL, apiKey: apiKey) { result in
            
            switch result {
            case .success(let auth):
                completion(.success(auth))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func findAllPolicies(jamfServerURL: String, apiKey: String, completion: @escaping (Result<Policies, JamfError>) -> Void) {
        
        self.jamfService.findAllPolicies(jamfServerURL: jamfServerURL, apiKey: apiKey, token: "") { result in
            
            switch result {
                case .success(let policies):
                    //print("policies: \(policies)")
                    completion(.success(policies))
                case .failure(let error):
                    guard error.statusCode == 401 else {
                       // print("FindAllPolicies Error: \(error.statusCode) - \(error.localizedDescription)")
                        completion(.failure(error))
                        return
                    }

                    //MARK: Create Token
                    self.createAuthToken(jamfServerURL: jamfServerURL, apiKey: apiKey) { result in
                        switch result {
                            case .success(let auth):
                                self.jamfService.findAllPolicies(jamfServerURL: jamfServerURL, apiKey: apiKey, token: auth.token) { result in
                                    switch result {
                                        case .success(let policies):
                                            //print("policies Bearer: \(policies)")
                                            completion(.success(policies))
                                        case .failure(let error):
                                           // print("FindAllPolicies Bearer Error: \(error.statusCode) - \(error.localizedDescription)")
                                            completion(.failure(error))
                                    }
                                }
                            case .failure(let error):
                                //print("FindAllPolicies Bearer Auth Error: \(error.statusCode) - \(error.localizedDescription)")
                                completion(.failure(error))
                        }
                    }
                    
            }
        }
    }
    
    public func findPolicyById(policyId: Int, jamfServerURL: String, apiKey: String, flushPolicies: Bool, completion: @escaping (Result<PolicyResponse, JamfError>) -> Void) {
     
        self.jamfService.findPolicyById(policyId: policyId, jamfServerURL: jamfServerURL, apiKey: apiKey, token: "") { result in
            
            switch result {
            case .success(let result):
                if (flushPolicies && result.policy.general.enabled){
                    self.flushMatchingPolicies(jamfServerURL: jamfServerURL, apiKey: apiKey, id: policyId) { resp in
                        switch resp {
                            case .success(_) :
                                //print("Flushed")
                                break
                            case .failure(_) :
                                //print("Not Flushed")
                                break
                        }
                    }
                }
                completion(.success(result))
            case .failure(let error):
                guard error.statusCode == 401 else {
                    completion(.failure(error))
                    return
                }

                //MARK: Create Token
                self.createAuthToken(jamfServerURL: jamfServerURL, apiKey: apiKey) { result in
                    switch result {
                        case .success(let auth):
                        self.jamfService.findPolicyById(policyId: policyId, jamfServerURL: jamfServerURL, apiKey: apiKey, token: auth.token) { result in
                                switch result {
                                    case .success(let result):
                                        if (flushPolicies && result.policy.general.enabled){
                                            self.flushMatchingPolicies(jamfServerURL: jamfServerURL, apiKey: apiKey, id: policyId) { resp in
                                                switch resp {
                                                    case .success(_) :
                                                        break
                                                    case .failure(_) :
                                                        break
                                                }
                                            }
                                        }
                                        completion(.success(result))
                                    case .failure(let error):
                                        completion(.failure(error))
                                }
                            }
                        case .failure(let error):
                            completion(.failure(error))
                    }
                }
            }
        }
    }

    public func flushMatchingPolicies(jamfServerURL: String, apiKey: String, id: Int, completion: @escaping (Result<JamfResponse, JamfError>) -> Void) {
     
        self.jamfService.flushMatchingPolicies(jamfServerURL: jamfServerURL, apiKey: apiKey, id: id, token: "") { result in
            
            switch result {
            case .success(let policies):
                completion(.success(policies))
            case .failure(let error):
                guard error.statusCode == 401 else {
                    completion(.failure(error))
                    return
                }

                //MARK: Create Token
                self.createAuthToken(jamfServerURL: jamfServerURL, apiKey: apiKey) { result in
                    switch result {
                        case .success(let auth):
                        self.jamfService.flushMatchingPolicies(jamfServerURL: jamfServerURL, apiKey: apiKey, id: id, token: auth.token) { result in
                                switch result {
                                    case .success(let policies):
                                        completion(.success(policies))
                                    case .failure(let error):
                                        completion(.failure(error))
                                }
                            }
                        case .failure(let error):
                            completion(.failure(error))
                    }
                }
            }
        }
    }
}
