import Combine
import ComposableArchitecture
import Foundation
import web3swift

enum AssetListVM {
    static let reducer = Reducer<State, Action, Environment> { state, action, environment in
        switch action {
            case .startInitialize:
                guard !state.isInitialized else {
                    return .none
                }

                state.shouldShowHUD = true

                return PhotosManager.requestAuthorization()
                    .eraseToEffect()
                    .map(AssetListVM.Action.authorized)
            case .authorized(.authorized):
                return PhotosManager.fetchAssets()
                    .subscribe(on: environment.backgroundQueue)
                    .receive(on: environment.mainQueue)
                    .eraseToEffect()
                    .map(AssetListVM.Action.endInitialize)
            case .authorized(let status):
                return .none
            case .endInitialize(let assets):
                state.assets = assets
                state.isInitialized = true
                state.shouldShowHUD = false
                return .none
            case .startRefresh:
                state.shouldPullToRefresh = true

                return PhotosManager.fetchAssets()
                    .subscribe(on: environment.backgroundQueue)
                    .receive(on: environment.mainQueue)
                    .eraseToEffect()
                    .map(AssetListVM.Action.endRefresh)
            case .endRefresh(let assets):
                state.assets = assets
                state.shouldPullToRefresh = false
                return .none
            case .shouldShowHUD(let val):
                state.shouldShowHUD = val
                return .none
            case .shouldPullToRefresh(let val):
                state.shouldPullToRefresh = val
                return .none
            case .showUploadNftView(let asset):
                state.uploadNftView = MintNftVM.State(address: state.address, asset: asset)
                state.isPresentedUploadNftView = true
                return .none
            case .isPresentedUploadNftView(let val):
                state.isPresentedUploadNftView = val
                return .none
            case .uploadNftView(let action):
                switch action {
                    case .mint:
                        return .none
                    case .minted(.success(_)):
                        state.isPresentedUploadNftView = false
                        state.uploadNftView = nil
                        return .none
                    case .minted(.failure(_)):
                        return .none
                    case .back:
                        state.isPresentedUploadNftView = false
                        state.uploadNftView = nil
                        return .none
                    case .shouldShowHUD:
                        return .none
                }
        }
    }
    .connect(
        MintNftVM.reducer,
        state: \.uploadNftView,
        action: /AssetListVM.Action.uploadNftView,
        environment: { env in
            MintNftVM.Environment(
                mainQueue: env.mainQueue,
                backgroundQueue: env.backgroundQueue
            )
        }
    )
}

extension AssetListVM {
    enum Action: Equatable {
        case startInitialize
        case authorized(PhotoAuthorizationStatus)
        case endInitialize([ImageAsset])
        case startRefresh
        case endRefresh([ImageAsset])
        case shouldShowHUD(Bool)
        case shouldPullToRefresh(Bool)
        case isPresentedUploadNftView(Bool)
        case showUploadNftView(ImageAsset)

        case uploadNftView(MintNftVM.Action)
    }

    struct State: Equatable {
        let address: EthereumAddress

        var shouldShowHUD = false
        var shouldPullToRefresh = false
        var isInitialized = false
        var assets: [ImageAsset] = []
        var isPresentedUploadNftView = false

        var uploadNftView: MintNftVM.State?
    }

    struct Environment {
        let mainQueue: AnySchedulerOf<DispatchQueue>
        let backgroundQueue: AnySchedulerOf<DispatchQueue>
    }
}
