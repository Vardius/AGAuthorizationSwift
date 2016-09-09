//
//  AuthorizationService.swift
//  Authorization
//
//  Created by Angelo Giurano on 9/8/16.
//  Copyright © 2016 OpsTalent. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper

enum GrantType: String {
    case password = "password"
    case clientCredentials = "client_credentials"
    case refreshToken = "refresh_token"
}

enum AuthErrorType: ErrorType {
    case UnAuthorized(message: String)
}

final class AuthorizationService {
    
    var delegate: AuthViewControllerDelegate?
    
    static let sharedInstance = AuthorizationService()
    
    private init() {
        precondition(CONSTANTS.client_id != "", "Set client_id in Constants/Constants.swift")
        precondition(CONSTANTS.client_secret != "" , "Set client_id in Constants/Constants.swift")
        precondition(CONSTANTS.basePath != "", "Set basePath in Constants/Constants.swift")
    }
    
    var token_header: [String: String]? {
        get {
            return ["Authorization": "Bearer"]
        }
    }
    
    
    var loginParameters: [String: String] {
        get {
            let parameters: [String: String] = [CONSTANTS.AuthKeys.CLIENT_ID: CONSTANTS.client_id, CONSTANTS.AuthKeys.CLIENT_SECRET: CONSTANTS.client_secret, CONSTANTS.AuthKeys.GRANT_TYPE: GrantType.password.rawValue]
            return parameters
        }
    }
    
    func login(withUsername username: String, andPassword password: String) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        var parameters = loginParameters
        parameters += ["username": username, "password": password]
        
        Alamofire.request(.POST, CONSTANTS.AuthURLS.loginPath, parameters: parameters, encoding: .URL, headers: nil)
        .validate()
        .responseObject { [unowned self](response: Response<OAuthResponse, NSError>) in
            guard let _ = response.result.value where response.result.error == nil else {
                self.delegate?.loginDidFail(withError: AuthErrorType.UnAuthorized(message: "Couldn't Login"))
                return
            }
            
            self.delegate?.loginDidSucceed()
        }
    }
}