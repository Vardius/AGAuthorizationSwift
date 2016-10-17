//
//  HTTPClient.swift
//  Authorization
//
//  Created by Angelo Giurano on 9/20/16.
//  Copyright © 2016 OpsTalent. All rights reserved.
//
import Foundation
import Alamofire
import AlamofireObjectMapper
import ObjectMapper
import PromiseKit
import KeychainAccess

private class APIResponse<T : Mappable>: Mappable {
    var success: Bool = false
    var data: T?
    var error : APIError?
    
    
    required init?(_ map: Map) {}
    
    func mapping(map: Map) {
        success <- map["success"]
        data <- map["data"]
        error <- map["error"]
    }
}

enum APIError: ErrorType {
    case unAuthorizedError(String)
}


class HTTPClient : NSObject {
    static let sharedInstance = HTTPClient()
    
    
    //MARK: Helper functions
    func post<T : Mappable>(route : RouterType, parameters : [String : AnyObject]? = nil) -> Promise<T?> {
        return self.httpOperation(.POST, route: route, parameters: parameters)
    }
    
    func unauthorizedPost<T: Mappable>(route: RouterType, parameters : [String : AnyObject]? = nil) -> Promise<T?> {
        return self.httpOperationUnauthorized(.POST, route: route, parameters: parameters)
    }
    
    
    func post(route : RouterType, parameters : [String : AnyObject]? = nil) -> Promise<Void> {
        return self.httpOperationVoid(.POST, route: route, parameters: parameters)
    }
    
    func get<T : Mappable>(route : RouterType, parameters : [String : AnyObject]? = nil) -> Promise<T?> {
        return self.httpOperation(.GET, route: route, parameters : parameters);
    }
    
    func get(route : RouterType, parameters : [String : AnyObject]? = nil) -> Promise<Void> {
        return self.httpOperationVoid(.GET, route: route, parameters : parameters);
    }
    
    func getList<T: Mappable>(route : RouterType, parameters : [String : AnyObject]? = nil) -> Promise<[T]> {
        return self.httpOperationList(.GET, route: route, parameters: parameters)
    }
    
    func delete<T : Mappable>(route: RouterType, parameters: [String: AnyObject]? = nil) -> Promise<T?> {
        return self.httpOperation(.DELETE, route: route, parameters: parameters)
    }
    
    
    func delete(route: Router, parameters: [String: AnyObject]? = nil) -> Promise<Void> {
        return self.httpOperationVoid(.DELETE, route: route, parameters: parameters)
    }
    
    func put<T: Mappable>(route: RouterType, parameters: [String: AnyObject]? = nil) -> Promise<T?> {
        return self.httpOperation(.PUT, route: route, parameters: parameters)
    }
    
    private func httpOperation<T : Mappable>(method : Alamofire.Method, route : RouterType, let parameters : [String : AnyObject]? = nil) -> Promise<T?> {
        
        
        return Promise<T?> { (fulfill, reject) -> Void in
            
            AuthorizationService.sharedInstance.getValidToken()
                .then {
                    _ -> Void in
                    
                    guard let tokenHeader = AuthorizationService.token_header else {
                        reject(APIError.unAuthorizedError("Unauthorized"))
                        return
                    }
                    
                    func parsingError(erroString : String) -> NSError {
                        return NSError(domain: "com.paychores.error", code: -100, userInfo: nil)
                    }
                    
                    var encoding: ParameterEncoding = .URLEncodedInURL
                    
                    switch method {
                    case .POST:
                        encoding = ParameterEncoding.JSON
                    case .GET:
                        encoding = ParameterEncoding.URLEncodedInURL
                    case .DELETE:
                        encoding = ParameterEncoding.URL
                    case .PUT:
                        encoding = ParameterEncoding.JSON
                    default:
                        break
                    }
                    
                    request(method, route.URLString, parameters: parameters, encoding: encoding, headers: tokenHeader)
                        .responseJSON { (response) -> Void in
                            
                            if let error = response.result.error {
                                reject(error) //network error
                            }else {
                                if let apiResponse = Mapper<T>().map(response.result.value) {
                                    fulfill(apiResponse)
                                } else{
                                    let err = NSError(domain: "com.paychores.error", code: -101, userInfo: nil)
                                    reject(err)
                                }
                            }
                            
                    }
            }
        }
    }
    
    //    private func httpOperationList<T : Mappable>(method : Alamofire.Method, route : RouterType, let parameters : [String : AnyObject]? = nil) -> Promise<CountReply<T>> {
    //
    //        return Promise<CountReply<T>> { (fulfill, reject) -> Void in
    //
    //            AuthorizationService.sharedInstance.getValidToken()
    //            .then {
    //                _ -> Void in
    //
    //                guard let tokenHeader = AuthorizationService.token_header else {
    //                    reject(APIError.unAuthorizedError("Unauthorized"))
    //                    return
    //                }
    //
    //                func parsingError(erroString : String) -> NSError {
    //                    return NSError(domain: "com.paychores.error", code: -100, userInfo: nil)
    //                }
    //
    //                var encoding: ParameterEncoding = .URLEncodedInURL
    //
    //                switch method {
    //                case .POST:
    //                    encoding = ParameterEncoding.JSON
    //                case .GET:
    //                    encoding = ParameterEncoding.URLEncodedInURL
    //                default:
    //                    break
    //                }
    //
    //                request(method, route.URLString, parameters: parameters, encoding: encoding, headers: tokenHeader)
    //                .responseJSON { (response) -> Void in
    //
    //                    if let error = response.result.error {
    //                        reject(error) //network error
    //                    }else {
    //                        if let apiResponse = Mapper<CountReply<T>>().map(response.result.value) {
    //                            if apiResponse.success {
    //                                fulfill(apiResponse)
    //                            }else{
    //                                if let _ = apiResponse.error {
    //                                    reject(APIError.unAuthorizedError("UNauthorized"))
    //                                }else{
    //                                    reject(APIError.unAuthorizedError("UNauthorized"))
    //                                }
    //                            }
    //                        }else{
    //                            let err = NSError(domain: "com.paychores.error", code: -101, userInfo: nil)
    //                            reject(err)
    //                        }
    //                    }
    //                }
    //            }
    //        }
    //    }
    
    private func httpOperationList<T : Mappable>(method : Alamofire.Method, route : RouterType, let parameters : [String : AnyObject]? = nil) -> Promise<[T]> {
        
        return Promise<[T]> { (fulfill, reject) -> Void in
            
            AuthorizationService.sharedInstance.getValidToken()
                .then {
                    _ -> Void in
                    
                    guard let tokenHeader = AuthorizationService.token_header else {
                        reject(APIError.unAuthorizedError("Unauthorized"))
                        return
                    }
                    
                    func parsingError(erroString : String) -> NSError {
                        return NSError(domain: "com.paychores.error", code: -100, userInfo: nil)
                    }
                    
                    var encoding: ParameterEncoding = .URLEncodedInURL
                    
                    switch method {
                    case .POST:
                        encoding = ParameterEncoding.JSON
                    case .GET:
                        encoding = ParameterEncoding.URLEncodedInURL
                    default:
                        break
                    }
                    
                    Alamofire.request(method, route.URLString, parameters: parameters, encoding: encoding, headers: tokenHeader)
                        .validate()
                        .responseArray { (response: Response<[T], NSError>) in
                            if let apiResponse = response.result.value {
                                fulfill(apiResponse)
                                return
                            }
                            
                            if let error = response.result.error {
                                reject(error)
                                return
                            }
                    }
            }
        }
    }
    
    
    private func httpOperationVoid(method : Alamofire.Method, route : RouterType, let parameters : [String : AnyObject]? = nil) -> Promise<Void> {
        
        
        return Promise<Void> { (fulfill, reject) -> Void in
            
            AuthorizationService.sharedInstance.getValidToken()
                .then {
                    _ -> Void in
                    
                    guard let tokenHeader = AuthorizationService.token_header else {
                        reject(APIError.unAuthorizedError("Unauthorized"))
                        return
                    }
                    
                    func parsingError(erroString : String) -> NSError {
                        return NSError(domain: "com.wallbrand.error", code: -100, userInfo: nil)
                    }
                    
                    var encoding: ParameterEncoding = .URLEncodedInURL
                    
                    switch method {
                    case .POST:
                        encoding = ParameterEncoding.JSON
                    case .GET:
                        encoding = ParameterEncoding.URLEncodedInURL
                    case .DELETE:
                        encoding = ParameterEncoding.URL
                    default:
                        break
                    }
                    
                    request(method, route.URLString, parameters: parameters, encoding: encoding, headers: tokenHeader)
                        .responseJSON { (response) -> Void in
                            
                            if response.response?.statusCode == 200 {
                                fulfill()
                            } else {
                                reject(APIError.unAuthorizedError("Unauthorized"))
                            }
                    }
            }
        }
    }
    
    
    
    
    private func httpOperationUnauthorized<T: Mappable>(method : Alamofire.Method, route : RouterType, let parameters : [String : AnyObject]? = nil) -> Promise<T?> {
        
        
        return Promise<T?> { (fulfill, reject) -> Void in
            
            func parsingError(erroString : String) -> NSError {
                return NSError(domain: "com.paychores.com", code: -100, userInfo: nil)
            }
            
            var encoding: ParameterEncoding = .URLEncodedInURL
            
            switch method {
            case .POST:
                encoding = ParameterEncoding.URL
            case .GET:
                encoding = ParameterEncoding.URLEncodedInURL
            case .DELETE:
                encoding = ParameterEncoding.URL
            default:
                break
            }
            
            request(method, route.URLString, parameters: parameters, encoding: encoding, headers: nil)
                .responseJSON { (response) -> Void in
                    
                    if let error = response.result.error {
                        reject(error) //network error
                    }else {
                        if let apiResponse = Mapper<T>().map(response.result.value) {
                            fulfill(apiResponse)
                        }else{
                            let err = NSError(domain: "com.paychores.error", code: -101, userInfo: nil)
                            reject(err)
                        }
                    }
                    
            }
        }
    }
    
    
    func uploadFile(withData data: NSData, route : RouterType, let parameters : [String : AnyObject]? = nil) -> Promise<File?> {
        return Promise<File?> {
            fulfill, reject in
            AuthorizationService.sharedInstance.getValidToken()
                .then {
                _ -> Void in
                
                guard let tokenHeader = AuthorizationService.token_header else {
                    reject(APIError.unAuthorizedError("Unauthorized"))
                    return
                }
                
                Alamofire.upload(.POST, route.URLString, headers: tokenHeader, multipartFormData: {
                    multipartFormData in
                    multipartFormData.appendBodyPart(data: data, name: "file[file]",
                        fileName: "image.png", mimeType: "image/png")
                    }, encodingCompletion: {
                        encodingCompletionResult in
                        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                        switch encodingCompletionResult {
                        case .Success(request: let upload, streamingFromDisk: _, streamFileURL: _):
                            upload
                                .responseObject { response in
                                    fulfill(response.result.value)
                            }
                        case .Failure(let error):
                            reject(error)
                        }
                })
            }
        }
    }
}