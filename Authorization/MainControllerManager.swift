//
//  MainControllerManager.swift
//  Authorization
//
//  Created by Angelo Giurano on 10/17/16.
//  Copyright © 2016 OpsTalent. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import KeychainAccess

struct MainControllerManager {
    static var loggedInController: UIViewController {
        get {
            return UIViewController()
        }
    }
    
    static var unAuthorisedController: UIViewController {
        get {
            return UIViewController()
        }
    }
    
    static var mainViewController: UIViewController {
        get {
            let launchedWithToken = Keychain.sharedInstance.hasAccessToken
            
            if launchedWithToken {
                AuthorizationService.sharedInstance.getValidToken()
                    .then {
                        _ -> Void in
                        return
                    }.error {
                        error in
                        return
                }
                
                return loggedInController
            }
            else  {
                return unAuthorisedController
            }
        }
    }
}

