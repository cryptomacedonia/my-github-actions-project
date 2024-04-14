
import Alamofire
import SFRouting
import SwiftData
import SwiftUI

struct MainView: View {
    @Binding var selectedTab: Int
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var backActor: ActorForLocalExampleItem
    @EnvironmentObject private var sessionManager: SessionManagerWrapper
    @EnvironmentObject private var router: Router
    @EnvironmentObject var service: AppUtilsServiceProvider
    @Environment(\.scenePhase) private var scenePhase
    @Query() var userObjects: [UserDataObject]
    private var user: UserDataObject? { userObjects.first }
    @State private var refreshingInProgress = false

    var body: some View {
        ZStack(alignment: .top) {
            VStack {
                SfRouterView(router: router) { route in
                    switch route {
                    /// clean up the used routes only should be pplaced here!
                    case .tabsHome: HomeTabBarView(selectedTab: $selectedTab)
                    case .login: LoginView().ignoresSafeArea(.keyboard)
                    case .register: RegisterView()
                    case .splash:
                        Text("Loading...")
                    case .home:
                        Text("Home...")
                    case .settings:
                        Text("Settings...")
                    case .socialLogin:
                        SocialLoginScreen()
                    }
                }
            }
            .ignoresSafeArea(.keyboard).onAppear {
                if user == nil {
                    modelContext.insert(UserDataObject(role: 0))
                    try? modelContext.save()
                }
                let session = Session(interceptor: RequestInterceptor(modelContext: backActor.modelContext))
                service.afSession = session
                sessionManager.session = session
                router.replaceRoot(user?.accessToken == nil ? .login : .tabsHome)
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    /// this should take into account if we have user ,
                    /// have hostname etc! will not work if app is killed and started again!
                    if !refreshingInProgress && user?.accessToken != nil {
                        refreshingInProgress = true
                    }
                }
            }
        }
        .onAppear {
          // do something on appear...
        }
    }
}
