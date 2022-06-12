import Combine
import ComposableArchitecture
import Foundation
import web3swift

enum PhotoListVM {
    static let reducer = Reducer<State, Action, Environment> { state, action, environment in
        switch action {
            case .startInitialize:
                guard !state.isInitialized else {
                    return .none
                }

                state.shouldShowHUD = true

                return PhotosManager.requestAuthorization()
                    .eraseToEffect()
                    .map(PhotoListVM.Action.authorized)
            case .authorized(.authorized):
                return PhotosManager.fetchAssets()
                    .subscribe(on: environment.backgroundQueue)
                    .receive(on: environment.mainQueue)
                    .eraseToEffect()
                    .map(PhotoListVM.Action.endInitialize)
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
                    .map(PhotoListVM.Action.endRefresh)
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
        }
    }
}

extension PhotoListVM {
    enum Action: Equatable {
        case startInitialize
        case authorized(PhotoAuthorizationStatus)
        case endInitialize([PhotoAsset])
        case startRefresh
        case endRefresh([PhotoAsset])
        case shouldShowHUD(Bool)
        case shouldPullToRefresh(Bool)
    }

    struct State: Equatable {
        let address: EthereumAddress

        var shouldShowHUD = false
        var shouldPullToRefresh = false
        var isInitialized = false
        var assets: [PhotoAsset] = []
    }

    struct Environment {
        let mainQueue: AnySchedulerOf<DispatchQueue>
        let backgroundQueue: AnySchedulerOf<DispatchQueue>
    }
}
