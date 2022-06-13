import ComposableArchitecture
import Foundation
import web3swift

enum RootVM {
    static let reducer = Reducer<State, Action, Environment> { state, action, environment in
        switch action {
        case .startInitialize:
            return FirebaseAuthManager.shared.signInAnonymously()
                .flatMap { _ in return CloudFunctionClient().uploadIPFS() }
                .subscribe(on: environment.backgroundQueue)
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(RootVM.Action.endInitialize)
        case .endInitialize(.success(let id)):
            let privateKey = DataStore.shared.getPrivateKey()!
            let keystore = try! EthereumKeystoreV3(privateKey: privateKey)!
            let keyData = try! JSONEncoder().encode(keystore.keystoreParams)
            let address = keystore.addresses!.first!

            let keystoreManager = KeystoreManager([keystore])
            let pkData = try! keystoreManager.UNSAFE_getPrivateKeyData(password: "web3swift", account: address).toHexString()
            print("秘密鍵（開発用）: \(pkData)")

            state.nftListView = NftListVM.State(address: address)
            state.photoListView = PhotoListVM.State(address: address)
            state.walletView = WalletVM.State(address: address)
            return .none
        case .endInitialize(.failure(_)):
            return .none
        case .nftListView(let action):
            return .none
        case .photoListView(let action):
            return .none
        case .walletView(let action):
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
    .connect(
        PhotoListVM.reducer,
        state: \.photoListView,
        action: /RootVM.Action.photoListView,
        environment: { env in
            PhotoListVM.Environment(
                mainQueue: env.mainQueue,
                backgroundQueue: env.backgroundQueue
            )
        }
    )
    .connect(
        WalletVM.reducer,
        state: \.walletView,
        action: /RootVM.Action.walletView,
        environment: { env in
            WalletVM.Environment(
                mainQueue: env.mainQueue,
                backgroundQueue: env.backgroundQueue
            )
        }
    )
}

extension RootVM {
    enum Action: Equatable {
        case startInitialize
        case endInitialize(Result<String, AppError>)

        case nftListView(NftListVM.Action)
        case photoListView(PhotoListVM.Action)
        case walletView(WalletVM.Action)
    }

    struct State: Equatable {
        var nftListView: NftListVM.State?
        var photoListView: PhotoListVM.State?
        var walletView: WalletVM.State?
    }

    struct Environment {
        let mainQueue: AnySchedulerOf<DispatchQueue>
        let backgroundQueue: AnySchedulerOf<DispatchQueue>
    }
}
