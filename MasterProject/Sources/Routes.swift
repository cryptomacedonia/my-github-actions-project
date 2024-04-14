
import SFRouting
/// ununsed routes should be deleted
enum Routes: Hashable {
    case splash
    case tabsHome
    case login
    case home
    case register
    case settings
    case socialLogin
}

typealias Router = SfRouter<Routes>
