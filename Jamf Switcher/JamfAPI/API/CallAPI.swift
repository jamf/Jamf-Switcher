//
//  CallAPI.swift
//  Jamf Switcher
//
//  Created by David Norris on 23/05/2022.
//  Copyright © 2022 dataJAR. All rights reserved.
//

import Foundation
import Combine

public class CallAPI {
    
    public init() {}
    
    private let urlSession = URLSession.shared
    private let jsonDecoder = CommonUtils.jsonDecoder
    
    public func loadAndDecode<D: Decodable> (request: URLRequest, completion: @escaping(Result<D, JamfError>) -> ()){
        
        
        let dataTask = urlSession.dataTask(with: request) {data, resp, error in
            
            guard let statusCode = (resp as? HTTPURLResponse)?.statusCode else {
                completion(.failure(
                    JamfError(statusCode: 0, error: .noHostFound)
                ))
                return
            }
            
            guard let jsonData = data else {
                completion(.failure(
                    JamfError(statusCode: statusCode, error: .noData)
                ))
                return
            }
            
            guard error == nil && statusCode == 200 else {
                completion(.failure(
                    JamfError(statusCode: statusCode, error: .unknownError)
                ))
                return
            }
            
            if data != nil {
                do {
                    let response = try self.jsonDecoder.decode(D.self, from: jsonData)
                    self.executeCompletionHandlerInMainThread(with: .success(response), completion: completion)
                } catch let DecodingError.dataCorrupted(context) {
                    print(context)
                    self.executeCompletionHandlerInMainThread(with: .failure(JamfError(statusCode: statusCode, error: .dataCorrupted)), completion: completion)
                    return
                } catch let DecodingError.keyNotFound(key, context) {
                    print("Key '\(key)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                    self.executeCompletionHandlerInMainThread(with: .failure(JamfError(statusCode: statusCode, error: .keyNotFound)), completion: completion)
                    return
                } catch let DecodingError.valueNotFound(value, context) {
                    print("Value '\(value)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                    self.executeCompletionHandlerInMainThread(with: .failure(JamfError(statusCode: statusCode, error: .valueNotFound)), completion: completion)
                    return
                } catch let DecodingError.typeMismatch(type, context)  {
                    print("Type '\(type)' mismatch:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                    self.executeCompletionHandlerInMainThread(with: .failure(JamfError(statusCode: statusCode, error: .typeMisMatch)), completion: completion)
                    return
                } catch {
                    print("error: ", error)
                    self.executeCompletionHandlerInMainThread(with: .failure(JamfError(statusCode: statusCode, error: .unknownError)), completion: completion)
                    return
                }
            }
        }
        dataTask.resume()
    }
    
    public func execute (request: URLRequest, completion: @escaping(Result<JamfResponse, JamfError>) -> ()){
        
        
        let dataTask = urlSession.dataTask(with: request) {data, resp, error in
            
            guard let statusCode = (resp as? HTTPURLResponse)?.statusCode else {
                return
            }
            
            guard error == nil && (statusCode == 200 || statusCode == 201) else {
                completion(.failure(
                    JamfError(statusCode: statusCode, error: .unknownError)
                ))
                return
            }
            
            if data == nil && (statusCode == 200 || statusCode == 201) {
                completion(.success(JamfResponse(statusCode: statusCode)))
            }
        }
        dataTask.resume()
    }
    
    private func executeCompletionHandlerInMainThread<D: Decodable>(with result: Result<D, JamfError>, completion: @escaping (Result<D, JamfError>) -> ()) {
        DispatchQueue.main.async {
            completion(result)
        }
    }
    
}
