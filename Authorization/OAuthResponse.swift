//
//  OAuthResponse.swift
//  Authorization
//
//  Created by Angelo Giurano on 9/9/16.
//  Copyright © 2016 OpsTalent. All rights reserved.
//

import Foundation
import ObjectMapper
import KeychainAccess

final class OAuthResponse: Mappable {
    
    private var authToken: String?
    private var refreshToken: String?
    private var expiresIn: Int?
    
    required init?(_ map: Map) {
        guard let authToken = map.JSONDictionary[CONSTANTS.AuthKeys.accessTokenKey] as? String, refreshToken = map.JSONDictionary[CONSTANTS.AuthKeys.refreshTokenKey] as? String, expDate = map.JSONDictionary[CONSTANTS.AuthKeys.expDateKey] as? Int else {
            return nil
        }
        
        Keychain.sharedInstance.setValue(value: authToken, forKey: CONSTANTS.KeychainConstants.accessTokenKey)
        Keychain.sharedInstance.setValue(value: refreshToken, forKey: CONSTANTS.KeychainConstants.refreshTokenKey)
        Keychain.sharedInstance.setValue(value: "\(expDate)", forKey: CONSTANTS.KeychainConstants.expDateKey)
    }
    
    func mapping(map: Map) {
        authToken <- map[CONSTANTS.AuthKeys.accessTokenKey]
        refreshToken <- map[CONSTANTS.AuthKeys.refreshTokenKey]
        expiresIn <- map[CONSTANTS.AuthKeys.expDateKey]
    }
}