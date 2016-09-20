import Foundation
import Alamofire
import AlamofireObjectMapper
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
    
    var delegate: AuthViewControllerDelegate?
    
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
    
    
    func login(withUsername username: String, andPassword password: String) -> Promise<OAuthResponse?> {
        var parameters = AuthorizationService.loginParameters
        parameters += ["username": username, "password": password]
        return HTTPClient.sharedInstance.post(AuthRouter.login, parameters: parameters)
    }
    
    func getValidToken() -> Promise<OAuthResponse?> {
        let parameters = AuthorizationService.refreshTokenParameters
        return HTTPClient.sharedInstance.post(AuthRouter.refreshToken, parameters: parameters)
    }
}