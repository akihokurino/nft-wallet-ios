import ComposableArchitecture
import SwiftUI
import web3swift
import secp256k1

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
            let privateKeyFromEnv = Env["WALLET_SECRET"] ?? ""
            if privateKeyFromEnv.isEmpty {
                DataStore.shared.savePrivateKey(val: SECP256K1.generatePrivateKey()!)
            } else {
                let formattedKey = privateKeyFromEnv.trimmingCharacters(in: .whitespacesAndNewlines)
                DataStore.shared.savePrivateKey(val: Data.fromHex(formattedKey)!)
            }
        }
        
        return true
    }
}
