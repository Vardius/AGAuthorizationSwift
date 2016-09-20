//
//  Router.swift
//  Authorization
//
//  Created by Angelo Giurano on 9/20/16.
//  Copyright © 2016 OpsTalent. All rights reserved.
//

import Foundation

protocol RouterType {
    var URLString: String { get }
}

public enum Router: RouterType {
    private static let baseURLString = ""
    
    public var URLString : String {
        let path : String = {
            switch self {
            default:
                return ""
            }
        }()
        return Router.baseURLString + path
    }
}