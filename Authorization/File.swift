//
//  File.swift
//  Authorization
//
//  Created by Angelo Giurano on 10/17/16.
//  Copyright © 2016 OpsTalent. All rights reserved.
//

import Foundation
import ObjectMapper

struct File: Mappable {
    var path: String?
    var name: String?

    init?(_ map: Map) {}
    
    mutating func mapping(map: Map) {
        path <- map["path"]
        name <- map["name"]
    }
}