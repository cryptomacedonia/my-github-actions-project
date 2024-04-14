
import Alamofire
import Foundation
import Pulse
import SwiftData
import SwiftUI

protocol AppUtilsProvider: ObservableObject {
    var afSession: Session? { get set }
    var modelContext: ModelContext? { get set }

    func onLogin(username: String,
                 password: String,

                 completion: @escaping (Result<LoginResponseObject, CustomError>) -> Void)

    func onRegister(name: String,
                    email: String,
                    password: String,
                    completion: @escaping (CustomError?) -> Void)
}

class AppUtilsServiceProvider: AppUtilsProvider {
    var afSession: Session?
    var modelContext: ModelContext?
    @Published var service: any AppUtilsProvider
    init(service: any AppUtilsProvider) {
        self.service = service
        modelContext = service.modelContext
        afSession = service.afSession
    }

    func onLogin(username: String,
                 password: String,
                
                 completion: @escaping (Result<LoginResponseObject, CustomError>) -> Void) {
        service.onLogin(username: username,
                                   password: password,
                                   completion: completion)
    }

    func onRegister(name: String,
                    email: String,
                    password: String,
                    completion: @escaping (CustomError?) -> Void) {
        service.onRegister(name: name,
                                      email: email,
                                      password: password,
                                      completion: completion)
    }

}

class AppUtilsService: AppUtilsProvider {
    var afSession: Alamofire.Session?
    var modelContext: ModelContext?

    func onRegister(name: String,
                    email: String,
                    password: String,
                    completion: @escaping (CustomError?) -> Void) {
        guard let user = getUser(modelContext: modelContext) else { return }
        guard let hostName = user.hostName,
              let url = URL(string: "\(hostName)/user/register") else {
            completion(.couldntRegisterTheUser("host name issue!"))
            return
        }
        let obj = RegisterRequestBodyObj(name: name, email: email, password: password)
        afSession?.request(url,
                           method: .post,
                           parameters: obj,
                           encoder: JSONParameterEncoder.default)
            .validate(statusCode: 200 ..< 300).responseString { rez in
                completion(rez.response?.statusCode == 200
                    ? nil
                    : .couldntRegisterTheUser(rez.error?.localizedDescription ?? "Register error"))
            }
        struct RegisterRequestBodyObj: Codable {
            let name: String
            let email: String
            let password: String
            var role = 0
        }
    }

    func onLogin(username: String, password: String,
                 completion: @escaping (Result<LoginResponseObject, CustomError>) -> Void) {
        if username == "demo" {
            completion(.success(LoginResponseObject(tokenType: "notype", accessToken: "access123", expiresIn: 3000, refreshToken: "refresh!@#", userId: "userDemoId")))
            return
        }
        guard let user = getUser(modelContext: modelContext) else { return }
        guard let hostName = user.hostName else { completion(.failure(.loginError("no user!"))); return }
        let url = "\(hostName)/user/login"
        afSession?.request(url,
                           method: .post,
                           parameters: LoginRequestObject(email: username, password: password),
                           encoder: JSONParameterEncoder.default)
            .responseDecodable(of: LoginResponseObject.self) { rez in
                switch rez.result {
                case let .success(obj):
                    user.refreshToken = obj.refreshToken
                    user.accessToken = obj.accessToken
                    user.userId = obj.userId
                    completion(.success(obj))
                case let .failure(error):
                    completion(.failure(.loginError(error.localizedDescription)))
                }
            }
        struct LoginRequestObject: Codable {
            let email: String
            let password: String
        }
    }
}
