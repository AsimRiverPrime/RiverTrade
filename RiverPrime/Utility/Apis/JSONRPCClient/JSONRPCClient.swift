//
//  JSONRPCClient.swift
//  RiverPrime
//
//  Created by Macbook on 16/09/2024.
//

import Foundation
import Alamofire
import SVProgressHUD

protocol IJSONRPCClient: AnyObject {
    func sendData<T: Encodable>(endPoint: Endpoint, method: HTTPMethod,request: JSONRPCRequest<T>, completion: @escaping (Result<Data?, Error>) -> Void)
    func sendData(endPoint: Endpoint, method: HTTPMethod, jsonrpcBody: [String: Any], showLoader: Bool, showLoaderWithStatus: Bool?, completion: @escaping (Result<Any?, Error>) -> Void)
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
    
    func sendData(endPoint: Endpoint, method: HTTPMethod, jsonrpcBody: [String: Any], showLoader: Bool, showLoaderWithStatus: Bool? = nil, completion: @escaping (Result<Any?, Error>) -> Void) {
        
        let url = baseURL + endPoint.getEndpoint()
        
        if showLoaderWithStatus != nil {
            let progressLoadingLabel = "Loading..."
            if showLoader {SVProgressHUD.show(withStatus: progressLoadingLabel)}
        } else {
            if showLoader {SVProgressHUD.show()}
        }
        
        AF.request(url,
                   method: .post,
                   parameters: jsonrpcBody,
                   encoding: JSONEncoding.default,
                   headers: ["Content-Type": "application/json"])
        .validate()
        .responseJSON { (response: AFDataResponse<Any>) in
            if showLoader {SVProgressHUD.dismiss()}
            switch response.result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
    }
    
}
