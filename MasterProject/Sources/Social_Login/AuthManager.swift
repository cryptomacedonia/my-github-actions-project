//
//  App.swift
//  logintestbrisi1
//
//  Created by Igor Jovcevski on 7.1.24.
//

import AuthenticationServices
import FacebookLogin
import FacebookCore
import FBSDKCoreKit
import Foundation
import GoogleSignIn
import SwiftUI

enum SocialLoginType {
    case appleSignIn
    case facebook
    case google
}

struct SocialUser {
    let userName: String?
    let firstName: String?
    let lastName: String?
    let imgUrl: String?
    let token: String?
    let email: String?
    let userId: String?
    let loginType: SocialLoginType?
}

enum AuthError: Error {
    case failedToAuthenticate(String)
}

class AuthManager: NSObject, ObservableObject {
    // Your authentication logic here
    var appleSignCompletion: ((Result<SocialUser, AuthError>) -> Void)?
    override init() {
        FBSDKCoreKit.ApplicationDelegate.shared.application(UIApplication.shared, didFinishLaunchingWithOptions: nil)
    }

    func signInWithApple(completion: @escaping (Result<SocialUser, AuthError>) -> Void) {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        appleSignCompletion = completion
        controller.performRequests()
    }

    func signInWithFacebook(completion: @escaping (Result<SocialUser, AuthError>) -> Void) {
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["public_profile", "email"], from: UIApplication.shared.windows.first!.rootViewController) { result, error in
            if let error = error {
                completion(.failure(.failedToAuthenticate("Facebook Graph API request error: \(error.localizedDescription)")))
                return
            }
            guard let accessToken = AccessToken.current else {
                completion(.failure(.failedToAuthenticate("fb auth login error!")))
                return
            }
            let graphRequest = GraphRequest(graphPath: "me", parameters: ["fields": "id,first_name,last_name,email"], tokenString: accessToken.tokenString, version: nil, httpMethod: .get)

            graphRequest.start { _, result, error in
                if let error = error {
                    completion(.failure(.failedToAuthenticate("Facebook Graph API request error: \(error.localizedDescription)")))
                    return
                }
                guard let result = result as? [String: Any] else {
                    completion(.failure(.failedToAuthenticate("fb auth error!")))
                    return
                }
                if let firstName = result["first_name"] as? String,
                   let lastName = result["last_name"] as? String,
                   let fbId = result["id"] as? String,
                   let email = result["email"] as? String {
                    completion(.success(SocialUser(userName: nil, firstName: firstName, lastName: lastName, imgUrl: nil, token: accessToken.tokenString, email: email, userId: fbId, loginType: .facebook)))
                }
            }
        }
    }

    func signInWithGoogle(completion: @escaping (Result<SocialUser, AuthError>) -> Void) {
        if let vc = UIApplication.shared.windows.first?.rootViewController {
            GIDSignIn.sharedInstance.signIn(withPresenting: vc) { result, error in
                if let error = error {
                    completion(.failure(.failedToAuthenticate("Google sign-in error: \(error.localizedDescription)")))
                    return
                }

                guard let user = result?.user else {
                    completion(.failure(.failedToAuthenticate("Google sign-in result is nil")))
                    return
                }

                let accessToken = user.accessToken
                let idToken = user.idToken

                let userId = user.userID
                let fullName = user.profile?.name
                let givenName = user.profile?.givenName
                let familyName = user.profile?.familyName
                let email = user.profile?.email
                let imageUrl = user.profile?.imageURL(withDimension: 100)?.absoluteString

                // Now you have the user details, and you can use them as needed
                print("User ID: \(userId ?? "")")
                print("Full Name: \(fullName ?? "")")
                print("Given Name: \(givenName ?? "")")
                print("Family Name: \(familyName ?? "")")
                print("Email: \(email ?? "")")
                print("Image URL: \(imageUrl ?? "")")
                print("Access token: \(accessToken.tokenString)")
                print("ID token: \(idToken?.tokenString ?? "")")

                completion(.success(SocialUser(userName: userId, firstName: givenName, lastName: familyName, imgUrl: imageUrl, token: accessToken.tokenString, email: email, userId: userId, loginType: .google)))
            }
        }
    }
}

extension AuthManager: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        UIApplication.shared.windows.first!
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        //       // Handle Apple ID sign-in success
        //        // Extract user information from authorization.credential
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            // Create an account in your system.
            let userIdentifier = appleIDCredential.user
            let userFirstName = appleIDCredential.fullName?.givenName
            let userLastName = appleIDCredential.fullName?.familyName
            let userEmail = appleIDCredential.email

            appleSignCompletion?(.success(SocialUser(userName: nil, firstName: userFirstName, lastName: userLastName, imgUrl: nil, token: nil, email: userEmail, userId: userIdentifier, loginType: .appleSignIn)))
            // Navigate to other view controller
        } else if let passwordCredential = authorization.credential as? ASPasswordCredential {
            // Sign in using an existing iCloud Keychain credential.
            let username = passwordCredential.user
            let password = passwordCredential.password
            appleSignCompletion?(.success(SocialUser(userName: username, firstName: nil, lastName: nil, imgUrl: nil, token: nil, email: nil, userId: passwordCredential.user, loginType: .appleSignIn)))
            // Navigate to other view controller
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Apple ID sign-in error: \(error.localizedDescription)")
        appleSignCompletion?(.failure(.failedToAuthenticate("Apple Sign in failed!")))
    }
}

struct SocialLoginScreen: View {
    @ObservedObject var authManager = AuthManager()

    var body: some View {
        VStack {
            Text("Welcome to Your App")

            Button("Sign in with Apple") {
                authManager.signInWithApple { rez in
                    print(rez)
                }
            }
            .padding()

            Button("Sign in with Facebook") {
                authManager.signInWithFacebook { rez in
                    print(rez)
                }
            }
            .padding()

            Button("Sign in with Google") {
                authManager.signInWithGoogle { rez in
                    print(rez)
                }
            }
            .padding()
        }
        .padding()
        .onOpenURL { url in
                            // Handle the URL here
                            ApplicationDelegate.shared.application(UIApplication.shared, open: url, options: [:])
                        }
    }
}

struct SocialLoginScreen_Previews: PreviewProvider {
    static var previews: some View {
        SocialLoginScreen()
    }
}
