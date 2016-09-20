//
//  AuthorizationTests.swift
//  AuthorizationTests
//
//  Created by Angelo Giurano on 9/8/16.
//  Copyright © 2016 OpsTalent. All rights reserved.
//

import XCTest
@testable import Authorization

class AuthorizationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testLoginShouldSucceed() {
        let authVC = TestAuthorizationViewController()

        AuthorizationService.sharedInstance.delegate = authVC
        
        let expectation = expectationWithDescription("Login succeeded")
        authVC.loginSucceded = {
            expectation.fulfill()
        }

        authVC.login(withUsername: "patient@patient.com", andPassword: "Test1234!")
        waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testLoginShouldFail() {
        let authVC = TestAuthorizationViewController()
        AuthorizationService.sharedInstance.delegate = authVC
        
        let expectation = expectationWithDescription("Login failed")
        authVC.loginFailed = {
            expectation.fulfill()
        }
        
        authVC.login(withUsername: "patient@patiet.com", andPassword: "Test1234!")
        waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
