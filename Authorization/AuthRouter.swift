//
//  AuthRouter.swift
//  Authorization
//
//  Created by Angelo Giurano on 9/20/16.
//  Copyright © 2016 OpsTalent. All rights reserved.
//

import Foundation

public enum AuthRouter: RouterType {
    private static let baseURLString = ""
    
    case login
    case refreshToken
    case register(String)
    
    public var URLString : String {
        let path : String = {
            switch self {
            case .login:
                return CONSTANTS.AuthURLS.loginPath
            case .refreshToken:
                return CONSTANTS.AuthURLS.refreshTokenPath
            case .register(let token):
                return CONSTANTS.AuthURLS.registerPath + "?access_token=\(token)"
            }
        }()
        return AuthRouter.baseURLString + path
    }
}