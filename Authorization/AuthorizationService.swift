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
import KeychainAccess

enum GrantType: String {
    case password = "password"
    case clientCredentials = "client_credentials"
    case refreshToken = "refresh_token"
}

enum AuthErrorType: ErrorType {
    case WrongPassword(message: String, code: Int?)
    case UnAuthorized(message: String, code: Int?)
    case GenericError(message: String)
    
    init(statusCode: Int?) {
        switch statusCode {
        case 400?:
            self = AuthErrorType.WrongPassword(message: "Wrong combination", code: statusCode)
        case 401?:
            self = AuthErrorType.UnAuthorized(message: "Invalid access token", code: statusCode)
        default:
            self = AuthErrorType.GenericError(message: "An error has occured")
        }
    }
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
            guard let token = Keychain.sharedInstance.accessToken else { return nil }
            return ["Authorization": "Bearer \(token)"]
        }
    }
    
    
    var loginParameters: [String: String] {
        get {
            let parameters: [String: String] = [CONSTANTS.AuthKeys.CLIENT_ID: CONSTANTS.client_id, CONSTANTS.AuthKeys.CLIENT_SECRET: CONSTANTS.client_secret, CONSTANTS.AuthKeys.GRANT_TYPE: GrantType.password.rawValue]
            return parameters
        }
    }
    
    var refreshTokenParameters: [String: String]? {
        get {
            guard let refreshToken = Keychain.sharedInstance.refreshToken else { return nil }
            let parameters: [String: String] = [CONSTANTS.AuthKeys.CLIENT_ID: CONSTANTS.client_id, CONSTANTS.AuthKeys.CLIENT_SECRET: CONSTANTS.client_secret, CONSTANTS.AuthKeys.GRANT_TYPE: GrantType.refreshToken.rawValue, CONSTANTS.AuthKeys.refreshTokenKey: refreshToken]
            return parameters
        }
    }
    
    private var triedRefresh = false
    
    func retryAfterRefresh(fn: () -> Void) {
        guard let parameters = refreshTokenParameters else { return }
        triedRefresh = true
        Alamofire.request(.POST, CONSTANTS.AuthURLS.refreshTokenPath, parameters: parameters, encoding: .URL, headers: nil)
        .validate()
        .responseObject { (response: Response<OAuthResponse, NSError>) in
            if response.response?.statusCode == 200 {
                fn()
            } else {
                self.delegate?.loginDidFail(withError: AuthErrorType.init(statusCode: response.response?.statusCode))
            }
            return
        }
    }
    
    func login(withUsername username: String, andPassword password: String) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        var parameters = loginParameters
        parameters += ["username": username, "password": password]
        
        Alamofire.request(.POST, CONSTANTS.AuthURLS.loginPath, parameters: parameters, encoding: .URL, headers: nil)
        .responseObject { [unowned self](response: Response<OAuthResponse, NSError>) in
            guard let _ = response.result.value where response.result.error == nil else {
                self.delegate?.loginDidFail(withError: AuthErrorType.init(statusCode: response.response?.statusCode))
                return
            }
            self.delegate?.loginDidSucceed()
        }
    }
}