
import Foundation
import Alamofire
import AlamofireObjectMapper
import ObjectMapper
import KeychainAccess
import PromiseKit

enum GrantType: String {
    case password = "password"
    case clientCredentials = "client_credentials"
    case refreshToken = "refresh_token"
}

enum AuthErrorType: ErrorType {
    case WrongPassword(message: String, code: Int?)
    case UnAuthorized(message: String, code: Int?)
    case GenericError(message: String)
    
    init(statusCode: Int?) {
        switch statusCode {
        case 400?:
            self = AuthErrorType.WrongPassword(message: "Wrong combination", code: statusCode)
        case 401?:
            self = AuthErrorType.UnAuthorized(message: "Invalid access token", code: statusCode)
        default:
            self = AuthErrorType.GenericError(message: "An error has occured")
        }
    }
}

final class AuthorizationService {
    
    static let sharedInstance = AuthorizationService()
    
    private init() {}
    
    static var token_header: [String: String]? {
        get {
            guard let token = Keychain.sharedInstance.accessToken else { return nil }
            return ["Authorization": "Bearer \(token)"]
        }
    }
    
    
    static var loginParameters: [String: String] {
        get {
            let parameters: [String: String] = [CONSTANTS.AuthKeys.CLIENT_ID: CONSTANTS.client_id, CONSTANTS.AuthKeys.CLIENT_SECRET: CONSTANTS.client_secret, CONSTANTS.AuthKeys.GRANT_TYPE: GrantType.password.rawValue]
            return parameters
        }
    }
    
    static var refreshTokenParameters: [String: String]? {
        get {
            guard let refreshToken = Keychain.sharedInstance.refreshToken else { return nil }
            let parameters: [String: String] = [CONSTANTS.AuthKeys.CLIENT_ID: CONSTANTS.client_id, CONSTANTS.AuthKeys.CLIENT_SECRET: CONSTANTS.client_secret, CONSTANTS.AuthKeys.GRANT_TYPE: GrantType.refreshToken.rawValue, CONSTANTS.AuthKeys.refreshTokenKey: refreshToken]
            return parameters
        }
    }
    
    static var registerParameters: [String: String] {
        get {
            let parameters: [String: String] = [CONSTANTS.AuthKeys.CLIENT_ID: CONSTANTS.client_id, CONSTANTS.AuthKeys.CLIENT_SECRET: CONSTANTS.client_secret, CONSTANTS.AuthKeys.GRANT_TYPE: GrantType.clientCredentials.rawValue]
            return parameters
        }
    }
    
    
    func login(withUsername username: String, andPassword password: String) -> Promise<OAuthResponse?> {
        var parameters = AuthorizationService.loginParameters
        parameters += ["username": username, "password": password]
        return HTTPClient.sharedInstance.unauthorizedPost(AuthRouter.login, parameters: parameters)
    }
    
//    func register(form: RegisterForm, withToken token: String) -> Promise<User?> {
//        let parameters = ["user" : form.toJSON()]
//        return HTTPClient.sharedInstance.unauthorizedPost(AuthRouter.register(token), parameters: parameters)
//    }
    
    func getRegisterToken() -> Promise<String> {
        let parameters = AuthorizationService.registerParameters
        return getToken(AuthRouter.login, withParams: parameters)
    }
    
    func getValidToken() -> Promise<OAuthResponse?> {
        let parameters = AuthorizationService.refreshTokenParameters
        return getValidToken(AuthRouter.refreshToken, withParams: parameters)
    }
    
    
    private func getToken(route: RouterType, withParams parameters: [String: AnyObject]? = nil) -> Promise<String> {
        return Promise<String> { (fulfill, reject) -> Void in
            
            func parsingError(erroString : String) -> NSError {
                return NSError(domain: "com.paychores.error", code: -100, userInfo: nil)
            }
            
            let encoding: ParameterEncoding = .URL
            
            
            request(.POST, route.URLString, parameters: parameters, encoding: encoding, headers: nil)
                .responseJSON { (response) -> Void in
                    
                    if let error = response.result.error {
                        reject(error) //network error
                    }else {
                        if let accessToken = response.result.value?[CONSTANTS.AuthKeys.accessTokenKey] as? String {
                            fulfill(accessToken)
                        }else{
                            let err = NSError(domain: "com.paychores.error", code: -101, userInfo: nil)
                            reject(err)
                        }
                    }
                    
            }
        }
    }
    
    private func getValidToken(route: RouterType, withParams parameters: [String: AnyObject]? = nil) -> Promise<OAuthResponse?> {
        return Promise<OAuthResponse?> { (fulfill, reject) -> Void in
            
            guard Keychain.sharedInstance.accessTokenIsExpired else {
                fulfill(OAuthResponse())
                return
            }
            
            func parsingError(erroString : String) -> NSError {
                return NSError(domain: "com.paychores.error", code: -100, userInfo: nil)
            }
            
            let encoding: ParameterEncoding = .URL
            
            
            request(.POST, route.URLString, parameters: parameters, encoding: encoding, headers: nil)
                .responseJSON { (response) -> Void in
                    if let error = response.result.error {
                        reject(error) //network error
                    } else {
                        if let apiResponse = Mapper<OAuthResponse>().map(response.result.value) {
                            fulfill(apiResponse)
                        }else{
                            let err = NSError(domain: "com.paychores.error", code: -101, userInfo: nil)
                            reject(err)
                        }
                    }
            }
        }
    }
    
    func logout() {
        Keychain.sharedInstance.logOut()
        let appDelegate = UIApplication.sharedApplication().delegate
        appDelegate?.window!!.rootViewController = MainControllerManager.mainViewController
    }
}