//
//  PolicyLogic.swift
//  Jamf Switcher
//
//  Created by David Norris on 23/05/2022.
//  Copyright © 2022 dataJAR. All rights reserved.
//

import Foundation
import Cocoa

public class PolicyLogic {
    
    public func processMyPolicies(apiKey: String, myPolicies: Policies, policyToFind: String, flushPolicies: Bool, jssURL: String, policyName: String, token: String, processedJSSCount: Int, jssCount: Int) -> (fileName: String, csvText: String) {
        let policyReport = processMyPoliciesReport(apiKey: apiKey, myPolicies: myPolicies, policyToFind: policyToFind, flushPolicies: flushPolicies, jssURL: jssURL, policyName: policyName, token: token)
        
        if processedJSSCount == jssCount {
            let csvText = policyReport.joined(separator: "\n")
            if flushPolicies {
                let fileName = "Policy Flush - " + policyToFind
                return (fileName, csvText)
            } else {
                let fileName = "Policy Search - " + policyToFind
                return (fileName, csvText)
            }
        }
        return ("","")
    }
    
    public func processMyPoliciesReport(apiKey: String, myPolicies: Policies, policyToFind: String, flushPolicies: Bool, jssURL: String, policyName: String, token: String) -> [String] {
        var policyReport = [String]()
        
        let foundPolices = retrieveFoundPolicy(myPolices: myPolicies, policyToFind: policyToFind)
        let foundPolicesFormated = retrieveFoundPolicyFormatted(foundPolices: foundPolices)
        
        if foundPolices.count > 0 {
            if flushPolicies {
                for policy in foundPolices {
                    JamfLogic().findPolicyById(policyId: policy.id, jamfServerURL: jssURL, apiKey: apiKey, token: token) { result in
                        switch result {
                            
                        case .success(let foundPolicy):
                            if foundPolicy.policy.general.enabled {
                                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100) , execute: {
                                    //MARK: FlushMatchPolices by making API Call
                                    JamfLogic().flushMatchingPolicies(jamfServerURL: jssURL, apiKey: apiKey, id: policy.id, token: token) { result in
                                        switch result {
                                            
                                        case .success(let result):
                                            print(result)
                                        case .failure(let error):
                                            print(error)
                                        }
                                    }
                                })
                            }
                        case .failure(let error):
                            print(error)
                        }
                    }
                    
                }
            }
            if flushPolicies {
                policyReport.append("\"\(policyName)\"" + "," + jssURL + "," + "\"\(foundPolicesFormated)\"" + "," + "Flushed")
            } else {
                policyReport.append("\"\(policyName)\"" + "," + jssURL + "," + "\"\(foundPolicesFormated)\"" + "," + "Found")
            }
        } else {
                policyReport.append("\"\(policyName)\"" + "," + jssURL + "," + "" + ","  + "Not Found")
        }
        return policyReport
    }
    
    public func retrieveFoundPolicy(myPolices: Policies, policyToFind: String) -> [Policy] {
        let foundPolices = myPolices.policies.filter{$0.name.lowercased().contains(policyToFind.lowercased())}
        print(foundPolices)
        return foundPolices
    }
    
    public func retrieveFoundPolicyFormatted(foundPolices: [Policy]) -> String {
        var foundPolicesFormated = ""
        for policy in foundPolices {
            foundPolicesFormated = foundPolicesFormated + policy.name + "\r"
        }
        return foundPolicesFormated
    }
    
}
