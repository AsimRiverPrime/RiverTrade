import Foundation

class NetellerService {
    enum Environment {
        case test
        case production
        
        var baseUrl: String {
            switch self {
            case .test:
                return "https://api.test.paysafe.com/paymenthub/v1"
            case .production:
                return "https://api.paysafe.com/paymenthub/v1"
            }
        }
    }
    
    private let baseUrl: String
    private let keyUsername: String
    private let keyPassword: String
    
    init(environment: Environment = .test, keyUsername: String, keyPassword: String) {
        self.baseUrl = environment.baseUrl
        self.keyUsername = keyUsername
        self.keyPassword = keyPassword
    }
    
    func initiatePayment(amount: Double, currency: String, merchantRefId: String, completion: @escaping (Result<String, Error>) -> Void) {
        let url = URL(string: "\(baseUrl)/payments")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let credentials = "\(keyUsername):\(keyPassword)"
        guard let credentialData = credentials.data(using: .utf8) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to encode credentials"])))
            return
        }
        let base64Credentials = credentialData.base64EncodedString()
        print("\n base64Credentials: \(base64Credentials)\n")
        
        request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        
        let paymentRequest = NetellerPaymentRequest(
            clientId: "ddcde565-a15d-4c77-a863-028a6cb5bb6e", // Replace with actual client ID if required
            amount: Int(amount * 100),
            currency: currency,
            paymentType: "NETELLER",
            merchantRefNum: merchantRefId,
            returnLinks: [
                .init(rel: "on_completed", href: "yourapp://payment-callback"),
                .init(rel: "on_failed", href: "yourapp://payment-callback")
            ]
        )
        
        do {
            let jsonData = try JSONEncoder().encode(paymentRequest)
            request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                if let data = data, let rawResponse = String(data: data, encoding: .utf8) {
                    print("Raw API Response: \(rawResponse)")
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("HTTP Status Code: \(httpResponse.statusCode)")
                    if httpResponse.statusCode != 200 && httpResponse.statusCode != 201 {
                        let errorMessage = "API returned status code \(httpResponse.statusCode)"
                        completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                        return
                    }
                }
                
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data, options: []),
                      let jsonDict = json as? [String: Any],
                      let paymentHandleToken = jsonDict["paymentHandleToken"] as? String
                
                else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse JSON"])))
                    return
                }
                
                completion(.success(paymentHandleToken))
            }
            task.resume()
        } catch {
            completion(.failure(error))
        }
    }
}
