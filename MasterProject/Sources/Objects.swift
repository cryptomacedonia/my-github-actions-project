

import Alamofire
import CommonCrypto
import CoreData
import Foundation
import Kingfisher
import SwiftData
import SwiftUI

@Model class UserDataObject {
    var userId: String?
    var username: String?
    var hostName: String?
    var accessToken: String?
    var refreshToken: String?
    var usedQuota: UInt64?
    var role: Int = 0
    var currentRevision: Int = 0
    var ranBefore = false
    var justLoggedIn = true
    init(userId: String? = nil,
         username: String? = nil,
         hostName: String? = nil,
         accessToken: String? = nil,
         refreshToken: String? = nil,
         role: Int) {
        self.userId = userId
        self.username = username
        self.hostName = hostName
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.role = role
    }
}

actor ActorForLocalExampleItem: ModelActor, ObservableObject {
    let modelExecutor: any ModelExecutor
    let modelContainer: ModelContainer
    let modelContext: ModelContext
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        modelContext = ModelContext(modelContainer)
        modelExecutor = DefaultSerialModelExecutor(modelContext: modelContext)
    }
}

@Model class LocalExampleItem: Hashable {
    var itemId: String?
    var itemDescription: String?
    var type: String?
    var creationDate: Date?

    init(itemId: String?,description: String?, type: String?, creationDate: Date?
       ) {
        self.itemId = itemId
        self.creationDate = creationDate
        self.type = type
        self.itemDescription = description
    }
}

struct LoginResponseObject: Codable {
    // Login response object structure
    let tokenType: String?
    let accessToken: String?
    let expiresIn: Int?
    let refreshToken: String?
    var userId: String?
}



struct RegisterResponseBodyObj: Codable {
    let name: String
    let email: String
    let password: String
    var role = 0
}

// kingfisher related to use access token while getting the imgs!!!
class KingfisherTokenPlugin: ImageDownloadRequestModifier {
    init(user: UserDataObject) {
        self.user = user
    }

    var user: UserDataObject
// TODO : need to find way to refresh token if not valid.. probably best with expiry time
    func modified(for request: URLRequest) -> URLRequest? {
        var request = request
        if let token = user.accessToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
}

// add your network and other errors here!
enum CustomError: Error {
    case tokenRefreshError
    case generalNetworkError(String)
    case loginError(String)
    case couldntRegisterTheUser(String)
}

final class RequestInterceptor: Alamofire.RequestInterceptor {
    private let modelContext: ModelContext
    private var user: UserDataObject?

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        user = getUser(modelContext: modelContext)
    }

    func adapt(_ urlRequest: URLRequest,
               for session: Session,
               completion: @escaping (Result<URLRequest, Error>) -> Void) {
        user = user ?? getUser(modelContext: modelContext)
        guard urlRequest.url?.absoluteString.hasPrefix("https://api.authenticated.com") != true else {
            /// If the request does not require authentication, we can directly return it as unmodified.
            return completion(.success(urlRequest))
        }
        var urlRequest = urlRequest
        /// Set the Authorization header value using the access token.
        if let token = user?.accessToken {
            urlRequest.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        }

        completion(.success(urlRequest))
    }

    func retry(_ request: Request,
               for session: Session,
               dueTo error: Error,
               completion: @escaping (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 else {
            /// The request did not fail due to a 401 Unauthorized response.
            /// Return the original error and don't retry the request.
            return completion(.doNotRetryWithError(error))
        }

        refreshToken { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(obj):
                user?.refreshToken = obj.refreshToken
                user?.accessToken = obj.accessToken
                completion(.retry)
            case let .failure(error):
                completion(.doNotRetryWithError(error))
            }
        }
    }

    func refreshToken(completion:
        @escaping (Result<LoginResponseObject, CustomError>) -> Void) {
        guard let user = user,
              let hostName = user.hostName,
              let refreshToken = user.refreshToken else {
            completion(.failure(.tokenRefreshError))
            return
        }
        let url = "\(hostName)/user/refresh"
        AF.request(url,
                   method: .post,
                   parameters: ["refreshToken": refreshToken],
                   encoder: JSONParameterEncoder.default)
            .validate(statusCode: 200 ..< 300)
            .responseDecodable(of: LoginResponseObject.self) { rez in
                switch rez.result {
                case let .success(obj):
                    completion(.success(obj))
                case let .failure(error):
                    completion(.failure(.generalNetworkError(error.localizedDescription)))
                }
            }
    }
}
