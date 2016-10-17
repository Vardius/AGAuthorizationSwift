//
//  KeychainService.swift
//  Authorization
//
//  Created by Angelo Giurano on 9/8/16.
//  Copyright © 2016 OpsTalent. All rights reserved.
//

import Foundation
import KeychainAccess

extension Keychain {
    static let sharedInstance = Keychain(service: CONSTANTS.KeychainConstants.service)
    
    var accessToken: String? {
        guard let token = self[CONSTANTS.KeychainConstants.accessTokenKey] else {
            return nil
        }
        return token
    }
    
    var refreshToken: String? {
        guard let token = self[CONSTANTS.KeychainConstants.refreshTokenKey] else {
            return nil
        }
        return token
    }
    
    private var tokenExpDate: NSDate? {
        get {
            guard let expDate = self[CONSTANTS.KeychainConstants.expDateKey] else { return nil }
            let timeInterval = NSTimeInterval.init(expDate)
            return NSDate.init(timeIntervalSince1970: timeInterval!)
        }
    }
    
    var hasAccessToken: Bool {
        return self[CONSTANTS.KeychainConstants.accessTokenKey] != nil
    }
    
    var accessTokenIsExpired: Bool {
        get {
            guard let expDate = tokenExpDate else { return true }
            return expDate.earlierDate(NSDate()).isEqualToDate(expDate)
        }
    }
    
    func setValue(value value: String, forKey key: String) {
        self[key] = value
    }
    
    func logOut() {
        self[CONSTANTS.KeychainConstants.accessTokenKey] = nil
        self[CONSTANTS.KeychainConstants.refreshTokenKey] = nil
        self[CONSTANTS.KeychainConstants.expDateKey] = nil
    }
}