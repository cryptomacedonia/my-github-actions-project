
import SwiftData
import SwiftUI
struct SettingsScreen: View {
    let version: String? = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    let buildNumber: String? = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
    let revisionGit: String? = Bundle.main.object(forInfoDictionaryKey: "REVISION") as? String
    let branchGit: String? = Bundle.main.object(forInfoDictionaryKey: "BRANCH_NAME") as? String
    @EnvironmentObject var router: Router
    @Environment(\.modelContext) private var modelContext
    @Query() var userObjects: [UserDataObject]
    @State var hostName: String = ""
    var user: UserDataObject? { userObjects.first }
    var anyOfSettings: [String] { [
        hostName
    ] }

    var body: some View {
        NavigationView {
            ZStack {
                Form {
                    Section(header: Text("APP DETAILS")) {
                        Text("version:\(version ?? "")")
                            .listRowBackground(Color.app(.onSecondary)?.opacity(0.8))
                            .foregroundColor(Color.app(.secondary))
                        Text("build:\(buildNumber ?? "") \(branchGit ?? "") \(revisionGit ?? "")")
                            .listRowBackground(Color.app(.onSecondary)?.opacity(0.8))
                            .foregroundColor(Color.app(.secondary))
                    }
                    Section(header: Text("ACTIVE USER")) {
                        Text(user?.username ?? "")
                            .listRowBackground(Color.app(.onSecondary)?.opacity(0.8))
                            .foregroundColor(Color.app(.secondary))
                    }
                    Section(header: Text("Hostname address")) {
                        TextField("hostname", text: $hostName)
                            .listRowBackground(Color.app(.onSecondary)?.opacity(0.8))
                            .foregroundColor(Color.app(.secondary))
                    }
                    Section {
                        Button {
                            try? modelContext.delete(model: LocalExampleItem.self)
                            try? modelContext.delete(model: UserDataObject.self)
                            let defaultUser = UserDataObject(role: 0)
                            try? modelContext.insert(defaultUser)
                            try? modelContext.save()
                            if let documentsFolder = FileManager.default.urls(for: .documentDirectory,
                                                                              in: .userDomainMask).first {
//                            try? documentsFolder.emptyTheFolder()
                            }
                            router.replaceRoot(.login)
                        } label: {
                            Text("LOGOUT")
                        }.frame(maxWidth: .infinity)
                            .listRowBackground(Color.app(.onSecondary)?.opacity(0.8))
                            .foregroundColor(Color.app(.secondary))
                    }
                }.navigationBarTitle("Settings").appFont(.headLine)
            }.navigationBarHidden(true).background(.clear).ignoresSafeArea().toolbar(.hidden)
                .onChange(of: anyOfSettings) { _, _ in
                    user?.hostName = hostName
                }
        }.onAppear {
            hostName = user?.hostName ?? ""
        }
    }
}

