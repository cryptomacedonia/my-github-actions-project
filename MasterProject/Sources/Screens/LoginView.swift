
import Alamofire
import Pulse
import SwiftData
import SwiftUI
struct LoginView: View {
    // Environment variables
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var router: Router
    @EnvironmentObject var backActor: ActorForLocalExampleItem
    @EnvironmentObject private var sessionManager: SessionManagerWrapper
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var appService: AppUtilsServiceProvider
    @Query() var userObjects: [UserDataObject]
    var user: UserDataObject? { userObjects.first }

    // State variables for user input and settings
    @State var username: String = ""
    @State var password: String = ""

    @State var showRegistrationModal: Bool = false
    @State var loginErrorhappened: Bool = false

    var body: some View {
        ZStack {
            // background image - pixeld girl with umbr usd now!
            Image("background1")
                .resizable()
                .ignoresSafeArea(.all)
                .aspectRatio(UIScreen.main.bounds.width / UIScreen.main.bounds.height, contentMode: .fit)
                .opacity(0.15)
            VStack(alignment: .center) {
                Spacer(minLength: 50)
                Form {
                    Section {
                        VStack {
                            // show different logo based on dark or light scheme!!
                            Image("logo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .background(.clear)
                                .opacity(1.0)
//                            Text("server version: \(user?.serverVersion ?? "Not Available")").appFont(.caption1)
                        }.listRowBackground(Color.clear)
                    }
                    Section {
                        // Text fields for username and password
                        SFTextField(title: "username", regex: AppShared.Regex.email, text: $username, showErrors: false)
                            .appFont(.headLine)
                            .listRowBackground(Color.app(.outlineVariant).opacity(0.9))
                        SFTextField(title: "password", regex: AppShared.Regex.password, text: $password, showErrors: false)
                            .appFont(.headLine)
                            .listRowBackground(Color.app(.outlineVariant).opacity(0.9))
                    } header: {
                        Text("Login using your account details")
                            .appFont(.subHeadline)
                            .background(.clear)
                    }
                    Section {
                        VStack(alignment: .center) {
                            // Login button
                            Button("LOGIN") {
                                hideKeyboard()
                                SwiftSpinner.show("Login you in..")

                                appService.onLogin(username: username,
                                                           password: password
                                                          ) { loginResponse in
                                    switch loginResponse.publisher.result {
                                    case let .success(obj):
                                        LoggerStore.shared.storeMessage(label: "login ",
                                                                        level: .info,
                                                                        message: "login successful..")
//                                        DispatchQueue.main.async {
//                                            SwiftSpinner.show("Please wait a minute or two...")
//                                        }
                                        user?.username = username
                                        user?.accessToken = obj.accessToken
                                        user?.refreshToken = obj.refreshToken
                                        SwiftSpinner.hide()
                                        router.replaceRoot(.tabsHome)
                                    case .failure:
                                        SwiftSpinner.hide()
                                        loginErrorhappened = true
                                    }
                                }
                            }
                            .appFont(.subHeadline)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(Color.app(.background))
                        }
                        .listRowBackground(Color.app(.outline)?.opacity(0.7))
                    }

                    Section {
                        VStack(alignment: .center) {
                                Text("no account?").appFont(.subHeadline)
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(Color.app(.background))
                        }.listRowBackground(Color.app(.outline))
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationBarHidden(true)
            .background(.clear)
            .ignoresSafeArea()
            .sheet(isPresented: self.$showRegistrationModal) {
                RegisterView(isPresented: $showRegistrationModal, currentUserNameShown: $username)
            }
        }.alert("There was problem trying to log you in. Please check your credentials",
                isPresented: $loginErrorhappened) {
            Button("OK", role: .cancel) { }
        }
        .frame(maxWidth: .infinity)
        .ignoresSafeArea(.all)
        .onAppear {
            // setting up fields as saved in user obj!
            username = user?.username ?? ""
        }.onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {

            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
