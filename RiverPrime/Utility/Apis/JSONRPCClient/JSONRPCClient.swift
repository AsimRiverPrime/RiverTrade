//
//  JSONRPCClient.swift
//  RiverPrime
//
//  Created by Macbook on 16/09/2024.
//

import Foundation
import Alamofire

protocol IJSONRPCClient: AnyObject {
    func sendData<T: Encodable>(endPoint: Endpoint, method: HTTPMethod,request: JSONRPCRequest<T>, completion: @escaping (Result<Data?, Error>) -> Void)
}

class JSONRPCClient: IJSONRPCClient {
    
    static let instance = JSONRPCClient()
    
    private let baseURL = "https://mbe.riverprime.com"
    
    func sendData<T: Encodable>(endPoint: Endpoint, method: HTTPMethod, request: JSONRPCRequest<T>, completion: @escaping (Result<Data?, Error>) -> Void) {
        
        let url = baseURL + endPoint.getEndpoint()
        
        AF.request(url, method: method, parameters: request, encoder: JSONParameterEncoder.default)
            .responseData { response in
                switch response.result {
                case .success(let data):
                    completion(.success(data))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}
