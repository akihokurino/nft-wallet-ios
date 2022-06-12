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
            print("秘密鍵（開発用）: \(pkData)")
            
            state.nftListView = NftListVM.State(address: address)
            
            return .none
        case .nftListView(let action):
            return .none
        }
    }
    .connect(
        NftListVM.reducer,
        state: \.nftListView,
        action: /RootVM.Action.nftListView,
        environment: { env in
            NftListVM.Environment(
                mainQueue: env.mainQueue,
                backgroundQueue: env.backgroundQueue
            )
        }
    )
}

extension RootVM {
    enum Action: Equatable {
        case initialize

        case nftListView(NftListVM.Action)
    }

    struct State: Equatable {
        var nftListView: NftListVM.State?
    }

    struct Environment {
        let mainQueue: AnySchedulerOf<DispatchQueue>
        let backgroundQueue: AnySchedulerOf<DispatchQueue>
    }
}
