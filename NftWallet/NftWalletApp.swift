import ComposableArchitecture
import SwiftUI
import web3swift

@main
struct NftWalletApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
        
    let store: Store<RootVM.State, RootVM.Action> = Store(
        initialState: RootVM.State(),
        reducer: RootVM.reducer,
        environment: RootVM.Environment(
            mainQueue: .main,
            backgroundQueue: .init(DispatchQueue.global(qos: .background))
        )
    )
    
    var body: some Scene {
        WindowGroup {
            RootView(store: store)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        let privateKey = DataStore.shared.getPrivateKey()
        if privateKey == nil {
            let newPrivateKey = SECP256K1.generatePrivateKey()!
            DataStore.shared.savePrivateKey(val: newPrivateKey)
        }
        
        return true
    }
}
