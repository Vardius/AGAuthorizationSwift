//
//  TestAuthorizationViewController.swift
//  Authorization
//
//  Created by Angelo Giurano on 9/14/16.
//  Copyright © 2016 OpsTalent. All rights reserved.
//

import UIKit
@testable import Authorization

class TestAuthorizationViewController: UIViewController, AuthViewControllerType, AuthViewControllerDelegate {
    var loginSucceded: (() -> ())?
    var loginFailed: (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loginDidSucceed() {
        loginSucceded?()
    }
    
    func loginDidFail(withError error: AuthErrorType) {
        loginFailed?()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
