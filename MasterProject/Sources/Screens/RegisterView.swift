
import Alamofire
import Foundation
import SwiftData
import SwiftUI

struct RegisterView: View {
    var usernameShownInParent: Binding<String>?
    @EnvironmentObject private var router: Router
    @EnvironmentObject private var sessionManager: SessionManagerWrapper
    @EnvironmentObject var appService: AppUtilsServiceProvider
    @Query() private var userObjects: [UserDataObject]
    private var user: UserDataObject? { userObjects.first }
    @State private var registerResultFromServerHappened = false
    @State private var registerNoticeAfterReceivingServerResult: String = ""
    @State private var wasRegistrationSuccessful: Bool = false
    @State var name: String = ""
    @State var email: String = ""
    @State var password: String = ""
    @State var passwordRepeated: String = ""
    var areFieldsValid: Bool {
        name.matches(AppShared.Regex.name.rawValue)
        && email.matches(AppShared.Regex.email.rawValue)
        && password.matches(AppShared.Regex.password.rawValue)
        && password == passwordRepeated && !name.isEmpty
    }

    var arePasswordsSame: Bool { password.matches(AppShared.Regex.password.rawValue) && password == passwordRepeated }
    var showRegistrationModal: Binding<Bool>?

    init(isPresented: Binding<Bool>? = nil, currentUserNameShown: Binding<String>? = nil) {
        showRegistrationModal = isPresented
        usernameShownInParent = currentUserNameShown
    }

    var body: some View {
        NavigationView {
            Form {
                Section {
                    // Text fields for username and password
                    SFTextField(title: "name", regex: AppShared.Regex.email, text: $name, showErrors: false)
                        .appFont(.headLine)
                        .listRowBackground(Color.app(.outlineVariant).opacity(0.9))

                    SFTextField(title: "email", regex: AppShared.Regex.email, text: $email, showErrors: false)
                        .appFont(.headLine)
                        .listRowBackground(Color.app(.outlineVariant).opacity(0.9))
                } header: {
                    Text("Enter your details")
                        .appFont(.subHeadline)
                        .background(.clear)
                }

                Section {
                    // Text fields for username and password
                    SFTextField(title: "password",
                                regex: AppShared.Regex.password,
                                text: $password,
                                showErrors: false)
                        .appFont(.headLine)
                        .listRowBackground(arePasswordsSame
                                           ? Color.app(.success).opacity(0.2)
                                           : Color.app(.outlineVariant).opacity(0.9))

                    SFTextField(title: "repeat password",
                                regex: AppShared.Regex.password,
                                text: $passwordRepeated,
                                showErrors: false)
                        .appFont(.headLine)
                        .listRowBackground(arePasswordsSame
                                           ? Color.app(.success).opacity(0.2)
                                           : Color.app(.outlineVariant).opacity(0.9))
                }

                Section {
                    Text("Password must contain one special character " +
                         "uppercase lowercase and be more than 6 characters").appFont(.caption2)
                }

                Section {
                    VStack(alignment: .center) {
                        Button("REGISTER") {
                            appService.onRegister(
                                                      name: name,
                                                      email: email,
                                                      password: password) { error in
                                    registerNoticeAfterReceivingServerResult = error == nil
                                    ? "Registration was successful, you can log in with your account details"
                                    : "There was problem trying to register this user." +
                                    " Please check your network connection"
                                    registerResultFromServerHappened = true
                                    user?.username = email
                                    wasRegistrationSuccessful = error == nil
                                    usernameShownInParent?.wrappedValue = email
                                    showRegistrationModal?.wrappedValue = true
                                }
                        }
                        .disabled(!areFieldsValid)
                        .appFont(.headLine)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(areFieldsValid ? Color.app(.background) : Color.app(.background)?.opacity(0.3))
                    }
                    .listRowBackground(Color.app(.outline))
                }

                Section {
                    VStack(alignment: .center) {
                        Button("CANCEL") {
                            showRegistrationModal?.wrappedValue = false
                        }
                        .appFont(.headLine)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(Color.app(.background))
                    }
                    .listRowBackground(Color.app(.outline)?.opacity(0.5))
                }

            }.navigationBarTitle("Register").appFont(.headLine)
        }.alert(registerNoticeAfterReceivingServerResult, isPresented: $registerResultFromServerHappened) {
            Button("OK", role: .cancel) {
                showRegistrationModal?.wrappedValue = !wasRegistrationSuccessful
            }
        }
    }
}
