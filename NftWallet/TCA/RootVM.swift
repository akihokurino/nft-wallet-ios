import ComposableArchitecture
import Foundation
import web3swift

enum RootVM {
    static let reducer = Reducer<State, Action, Environment> { state, action, environment in
        switch action {
        case .startInitialize:
            return FirebaseAuthManager.shared.signInAnonymously()
                .subscribe(on: environment.backgroundQueue)
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(RootVM.Action.endInitialize)
        case .endInitialize(.success(let id)):
            let address = EthereumManager.shared.address
            state.nftListView = NftListVM.State(address: address)
            state.photoListView = AssetListVM.State(address: address)
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
        AssetListVM.reducer,
        state: \.photoListView,
        action: /RootVM.Action.photoListView,
        environment: { env in
            AssetListVM.Environment(
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
        case photoListView(AssetListVM.Action)
        case walletView(WalletVM.Action)
    }

    struct State: Equatable {
        var nftListView: NftListVM.State?
        var photoListView: AssetListVM.State?
        var walletView: WalletVM.State?
    }

    struct Environment {
        let mainQueue: AnySchedulerOf<DispatchQueue>
        let backgroundQueue: AnySchedulerOf<DispatchQueue>
    }
}
