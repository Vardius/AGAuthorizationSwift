//
//  AuthViewControllerType.swift
//  Authorization
//
//  Created by Angelo Giurano on 9/8/16.
//  Copyright © 2016 OpsTalent. All rights reserved.
//

import Foundation


protocol AuthViewControllerType: class {
    func login(withUsername username: String, andPassword password: String)
}