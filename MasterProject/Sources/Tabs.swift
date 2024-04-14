
import SwiftUI

struct HomeTabBarView: View {
    @Binding var selectedTab: Int
    init(selectedTab: Binding<Int>) {
        UITabBar.appearance().backgroundColor = UIColor.app(.surface)
        _selectedTab = selectedTab
    }

    var body: some View {

        //tabsstart
        TabView(selection: $selectedTab) {
            HomeScreen()
	.tabItem {
		Label("Home", systemImage: "person.crop.square")
	}.tag(1)
	.toolbarBackground(Color.app(.surface)!, for: .tabBar)
	.toolbarBackground(.visible, for: .tabBar)

PurchasesScreen()
	.tabItem {
		Label("Purchases", systemImage: "checkmark.circle")
	}.tag(2)
	.toolbarBackground(Color.app(.surface)!, for: .tabBar)
	.toolbarBackground(.visible, for: .tabBar)

SettingsScreen()
	.tabItem {
		Label("Settings", systemImage: "gear")
	}.tag(3)
	.toolbarBackground(Color.app(.surface)!, for: .tabBar)
	.toolbarBackground(.visible, for: .tabBar)

SocialLoginScreen()
	.tabItem {
		Label("Extra", systemImage: "gear")
	}.tag(4)
	.toolbarBackground(Color.app(.surface)!, for: .tabBar)
	.toolbarBackground(.visible, for: .tabBar)


        }.tint(Color.app(.primary)).onChange(of: selectedTab) { prev, curr in
            print(prev, curr)
        }
    }
}
