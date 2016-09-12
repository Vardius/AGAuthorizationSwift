//
//  protocol AuthViewControllerDelegate.swift
//  Authorization
//
//  Created by Angelo Giurano on 9/9/16.
//  Copyright © 2016 OpsTalent. All rights reserved.
//

import Foundation

protocol AuthViewControllerDelegate: class {
    func loginDidSucceed()
    func loginDidFail(withError error: AuthErrorType)
}