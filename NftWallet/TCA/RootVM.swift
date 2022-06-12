import ComposableArchitecture
import Foundation
import web3swift

enum RootVM {
    static let reducer = Reducer<State, Action, Environment> { state, action, _ in
        switch action {
        case .initialize:
            let privateKey = DataStore.shared.getPrivateKey()!
            let keystore = try! EthereumKeystoreV3(privateKey: privateKey)!
            let keyData = try! JSONEncoder().encode(keystore.keystoreParams)
            let address = keystore.addresses!.first!

            let keystoreManager = KeystoreManager([keystore])
            let pkData = try! keystoreManager.UNSAFE_getPrivateKeyData(password: "web3swift", account: address).toHexString()
            print("secret: \(pkData)")
            return .none
        }
    }
}

extension RootVM {
    enum Action: Equatable {
        case initialize
    }

    struct State: Equatable {
        
    }

    struct Environment {
        let mainQueue: AnySchedulerOf<DispatchQueue>
        let backgroundQueue: AnySchedulerOf<DispatchQueue>
    }
}
