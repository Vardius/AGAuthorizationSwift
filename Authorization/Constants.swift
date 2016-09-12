//
//  Constants.swift
//  Authorization
//
//  Created by Angelo Giurano on 9/8/16.
//  Copyright © 2016 OpsTalent. All rights reserved.
//

import Foundation

struct CONSTANTS {
    static let basePath = "http://api-hb.ops-dev.pl/"
    
    static let client_id = "1_3h9h5utfplc0cckowwk0880o0o844so4wcw8kg0cggcw8w04so"
    static let client_secret = "4e2qvb529qqsc0sswk8wo0cs4ok4cgcc4c8wsk4osgss8ww0s"
    
    struct AuthURLS {
        static let loginPath = basePath + "oauth/v2/token"
        static let registerPath = basePath + ""
        static let refreshTokenPath = basePath + "oauth/v2/token"
        static let forgotPasswordPath = basePath + ""
    }
    
    struct AuthKeys {
        static let CLIENT_ID = "client_id"
        static let CLIENT_SECRET = "client_secret"
        static let GRANT_TYPE = "grant_type"
        static let accessTokenKey = "access_token"
        static let refreshTokenKey = "refresh_token"
        static let expDateKey = "expires_in"
    }
    
    struct KeychainConstants {
        static let service = ""
        static let accessTokenKey = ""
        static let refreshTokenKey = ""
        static let expDateKey = ""
    }
}