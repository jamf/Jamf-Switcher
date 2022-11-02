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
    
    public let jamfLogic = JamfLogic()
    
    public func retrieveFoundPolicy(myPolices: Policies, policyToFind: String) -> [Policy] {
        let foundPolices = myPolices.policies.filter{$0.name.lowercased().contains(policyToFind.lowercased())}
        //print(foundPolices)
        return foundPolices
    }
    
    public func retrieveFoundPolicyFormatted(foundPolices: [Policy]) -> String {
        var foundPolicesFormated = ""
        for policy in foundPolices {
            foundPolicesFormated = foundPolicesFormated + policy.name + "\r"
        }
        return foundPolicesFormated
    }
    
    public func processPolicy(foundPolicies: Policies, policyToFind: String, checkedJSSURL: String, apiKey: String, flushPolicies: Bool, instanceName: String, completion: @escaping(Result<[String], JamfError>) -> Void) {
        let foundPolices = retrieveFoundPolicy(myPolices: foundPolicies, policyToFind: policyToFind)
        let foundPolicesFormated = retrieveFoundPolicyFormatted(foundPolices: foundPolices)
        var policyReport = [String]()
        let dispatchGroup = DispatchGroup()

        if foundPolices.count > 0 {
            //print("FoundPolicies - \(foundPolices.count)")
            for policy in foundPolices {
                dispatchGroup.enter()
                jamfLogic.findPolicyById(policyId: policy.id, jamfServerURL: checkedJSSURL, apiKey: apiKey, flushPolicies: flushPolicies) { result in
                    switch result {
                        
                    case .success(let foundPolicy):
                        if (flushPolicies && foundPolicy.policy.general.enabled){
                            policyReport.append("\"\(instanceName)\"" + "," + checkedJSSURL + "," + "\"\(foundPolicesFormated)\"" + "," + "Flushed" + "," + "\"\(PolicyCheck(foundPolicy.policy.general.enabled))\"")
                            dispatchGroup.leave()
                        } else {
                            policyReport.append("\"\(instanceName)\"" + "," + checkedJSSURL + "," + "\"\(foundPolicesFormated)\"" + "," + "Found" + "," + "\"\(PolicyCheck(foundPolicy.policy.general.enabled))\"")
                            dispatchGroup.leave()
                        }
                        
                    case .failure( _):
                        policyReport.append("\"\(instanceName)\"" + "," + checkedJSSURL + "," + "\"\(foundPolicesFormated)\"" + "," + "Not Found")
                        dispatchGroup.leave()
                    }
                }
            }
        }
        dispatchGroup.notify(queue: .main) {
            completion(.success(policyReport))
        }
    }
}


private func PolicyCheck(_ policy: Bool) -> String {
    if policy {
        return "Enabled"
    } else {
        return "Disabled"
    }
}
