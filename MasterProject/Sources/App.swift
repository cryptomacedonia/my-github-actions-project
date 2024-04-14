
import Alamofire
import PulseUI
import SwiftData
import SwiftUI
import BackgroundTasks

@main
struct APP: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    private var router = Router(.splash)
    /// encapsulates Alamofire sessions
    @StateObject private var sessionManager = SessionManagerWrapper()

    //apis_here_insert

    private let container: ModelContainer
    @State private var showNetworkLogs = false

    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var service = AppUtilsService()
    @State var selectedTab = 0
    private var backGroundContext: ActorForLocalExampleItem
    init() {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: false, allowsSave: true)
        do {
            container = try ModelContainer(
                for: LocalExampleItem.self, UserDataObject.self,
                configurations: configuration)
            backGroundContext = ActorForLocalExampleItem(modelContainer: container)
        } catch {
            fatalError("app not init properly!")
        }
    }

    var body: some Scene {
        WindowGroup {
            MainView(selectedTab: $selectedTab)
                .environmentObject(backGroundContext)
                .environmentObject(AppUtilsServiceProvider(service: service))
                .environmentObject(sessionManager)
                .environmentObject(router)
                .modelContainer(container)
                .ignoresSafeArea(.keyboard).onShake {
                    showNetworkLogs = true
                }.sheet(isPresented: $showNetworkLogs) {
                    NavigationView {
                        /// shows Pulse network debug info.. should be removed for production!
                        ConsoleView()
                    }
                }.onAppear {
                    let user = getUser(modelContext: backGroundContext.modelContext)
                    let backDBContext = backGroundContext.modelContext
                    if user == nil {
                        backGroundContext.modelContext.insert(UserDataObject(role: 0))
                        try? container.mainContext.save()
                    }
                    let session = Session(interceptor: RequestInterceptor(modelContext: backDBContext))
                    service.afSession = session
                    service.modelContext = backDBContext
//                    appDelegate.service = service
                }.onChange(of: scenePhase) {
                    let user = getUser(modelContext: backGroundContext.modelContext)
                    switch scenePhase {
                    case .background:
                        // App is in the background
                        print("App went to the background")
                    default:
                        break
                    }
                }
        }
    }
}

class SessionManagerWrapper: ObservableObject {
    @Published var session: Session
    init() {
        session = Session()
    }
}
