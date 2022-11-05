import ComposableArchitecture
import Foundation

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
            state.nftListView = NftListVM.State()
            state.prepareMintPageView = PrepareMintPageVM.State(
                textToImageView: TextToImageVM.State(),
                assetListView: AssetListVM.State()
            )
            state.walletView = WalletVM.State()
            return .none
        case .endInitialize(.failure(_)):
            return .none
        case .nftListView(let action):
            return .none
        case .prepareMintPageView(let action):
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
        PrepareMintPageVM.reducer,
        state: \.prepareMintPageView,
        action: /RootVM.Action.prepareMintPageView,
        environment: { env in
            PrepareMintPageVM.Environment(
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
        case prepareMintPageView(PrepareMintPageVM.Action)
        case walletView(WalletVM.Action)
    }

    struct State: Equatable {
        var nftListView: NftListVM.State?
        var prepareMintPageView: PrepareMintPageVM.State?
        var walletView: WalletVM.State?
    }

    struct Environment {
        let mainQueue: AnySchedulerOf<DispatchQueue>
        let backgroundQueue: AnySchedulerOf<DispatchQueue>
    }
}
