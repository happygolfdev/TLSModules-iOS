//
//  RequestManager.swift
//  tlsmodule
//
//  Created by Justin Ji on 05/07/2019.
//  Copyright © 2019 tlsolution. All rights reserved.
//

import Foundation
import Alamofire

public typealias APICompletion = (NetworkResult) -> Void
public typealias JSONClosure = ([String: Any]?) -> Void

public class RequestManager: NSObject {
    
    
    public static func request(with request: TLSRequest,
                 _ user: User? = nil,
                 completionHandler completion: @escaping APICompletion) {

        guard let url = request.url else {
            Logger.showError(at: #function, type: .unsafelyWrapped(taget: "url"))
            completion(.error(message: "\(#function), 😱 url is nil"))
            return
        }
        
        var header = [String: String]()
        if let token = user?.token { header = ["authorization": token] }
        
        Alamofire.request(url, method: request.type,
                          parameters: request.body?.data,
                          encoding: JSONEncoding.default,
                          headers: header).response { (res) in
                            
            if let error = res.error {
                Logger.showError(at: #function, type: .network(errMsg: error.localizedDescription))
                completion(.error(message: error.localizedDescription))
                return
            }

            self.evaluateResponse(by: request, with: res, user, completion)
        }
    }
    
    private static func evaluateResponse(by request: TLSRequest,
                                        with dataRes: DefaultDataResponse,
                                        _ user: User?,
                                        _ completion: @escaping APICompletion) {
        
        guard let statusCode = dataRes.response?.statusCode else {
            completion(.error(message: "😱 statusCode is nil"))
            return
        }

        switch statusCode {
        case 200: completion(.success(data: dataRes.data))
        case 201: completion(.sucfulyDataModified(data: dataRes.data))
        case 400: completion(.invalidRequest)
        case 401: completion(.failure(issue: dataRes.error?.localizedDescription))
        case 403: completion(.notAuthroised)
        case 404: completion(.noData)
        case 409: completion(.cannotWrite)
        case 419: completion(.tokenExpired)
        case 500: completion(.serverError(message: dataRes.error?.localizedDescription))
        default: return
        }
    }

    public typealias TokenRenewalResult = (isSuccessful: Bool, newToken: String?)
    
    public static func renewToken(with request: TLSRequest,
                           of user: User,
                           completionHandler completion: @escaping ((TokenRenewalResult) -> Void)) {
        
        Alamofire.request(request.tokenRenewalURL,
                          method: .post,
                          parameters: ["Data": ["clientSecretKey": user.clientSecret]],
                          encoding: JSONEncoding.default,
                          headers: nil)

            .response { (res) in
                let statusCode = res.response?.statusCode

                if let _ = res.error {
                    completion((false, nil))
                    return
                }

                guard let data = res.data else {
                    completion((false, nil))
                    return
                }

                guard let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else {
                    completion((false, nil))
                    return
                }

                if statusCode == 200, let dataJSON = json["Data"] as? [String: Any], let token = dataJSON["token"] as? String {
                    completion((true, token))
                    return
                }

                completion((false, nil))
        }
    }
    
    
    /// HTTP 서버통신 결과를 완료해주는 함수 - Generic 데이터 모델 리턴
    ///
    /// - Parameters:
    ///   - apiResult: 통신 결과
    ///   - successAction: 성공했을 때
    ///   - tryAgainAction: 토큰 갱신 후 리턴
    public static func evaluate<T: Decodable>(by result: NetworkResult,
                                              _ successAction: ((T?) -> Void)?,
                                              _ failureAction: ((String?) -> Void)?,
                                              _ tryAgainAction: (() -> Void)? = nil) {
        
        switch result {
        case .success, .sucfulyDataModified:
            successAction?(result.model())
        case .tokenExpired:
            tryAgainAction?()
        default: failureAction?(result.errorMessage)
        }
    }
    
    /// HTTP 서버통신 결과를 완료해주는 함수 - JSON 리턴
    ///
    /// - Parameters:
    ///   - apiResult: 통신 결과
    ///   - successAction: 성공했을 때
    ///   - tryAgainAction: 토큰 갱신 후 리턴
    public static func evaluate(by result: NetworkResult,
                                _ successAction: JSONClosure?,
                                _ failureAction: ((String?) -> Void)?,
                                _ tryAgainAction: (() -> Void)? = nil) {
        
           switch result {
            case .success, .sucfulyDataModified:
                successAction?(result.json)
            case .tokenExpired:
                tryAgainAction?()
            default: failureAction?(result.errorMessage)
        }
    }

}
