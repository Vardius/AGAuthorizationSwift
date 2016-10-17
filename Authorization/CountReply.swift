//
//  CountReply.swift
//  Authorization
//
//  Created by Angelo Giurano on 9/20/16.
//  Copyright © 2016 OpsTalent. All rights reserved.
//

import Foundation
import ObjectMapper

struct CountReply<T: Mappable>: Mappable {
    var success: Bool = false
    var data: [T]?
    var pagination: Pagination?
    var error: APIError?
    
    init?(_ map: Map) {}
    
    init() {}
    
    mutating func mapping(map: Map) {
        success <- map["success"]
        data <- map["data"]
        pagination <- map["pagination"]
    }
}

internal struct Pagination: Mappable {
    var pageCount: Int?
    var currentPage: Int?
    var hasNextPage: Bool?
    var hasPrevPage: Bool?
    var count: Int?
    var limit: Int?
    
    init?(_ map: Map) {}
    
    mutating func mapping(map: Map) {
        pageCount <- map["page_count"]
        currentPage <- map["current_page"]
        hasNextPage <- map["has_next_page"]
        hasPrevPage <- map["has_prev_page"]
        count <- map["count"]
        limit <- map["limit"]
    }
}

