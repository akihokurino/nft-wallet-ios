import Combine
import ComposableArchitecture
import Foundation

enum NftListVM {
    static let reducer = Reducer<State, Action, Environment> { state, action, environment in
        switch action {
            case .startInitialize:
                guard !state.isInitialized else {
                    return .none
                }

                state.shouldShowHUD = true

                return OpenSeaClient.publish(
                    GetNftAssetsRequest(
                        owner: EthereumManager.shared.address,
                        limit: 50
                    )
                )
                .subscribe(on: environment.backgroundQueue)
                .receive(on: environment.mainQueue)
                .map { $0.nfts.map { NftAsset(data: $0) } }
                .catchToEffect()
                .map(NftListVM.Action.endInitialize)
            case .endInitialize(.success(let assets)):
                state.assets = assets
                state.isInitialized = true
                state.shouldShowHUD = false
                return .none
            case .endInitialize(.failure(_)):
                state.isInitialized = true
                state.shouldShowHUD = false
                return .none
            case .startRefresh:
                state.shouldPullToRefresh = true

                return OpenSeaClient.publish(
                    GetNftAssetsRequest(
                        owner: EthereumManager.shared.address,
                        limit: 50
                    )
                )
                .subscribe(on: environment.backgroundQueue)
                .receive(on: environment.mainQueue)
                .map { $0.nfts.map { NftAsset(data: $0) } }
                .catchToEffect()
                .map(NftListVM.Action.endRefresh)
            case .endRefresh(.success(let assets)):
                state.assets = assets
                state.shouldPullToRefresh = false
                return .none
            case .endRefresh(.failure(_)):
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

extension NftListVM {
    enum Action: Equatable {
        case startInitialize
        case endInitialize(Result<[NftAsset], AppError>)
        case startRefresh
        case endRefresh(Result<[NftAsset], AppError>)
        case shouldShowHUD(Bool)
        case shouldPullToRefresh(Bool)
    }

    struct State: Equatable {
        var shouldShowHUD = false
        var shouldPullToRefresh = false
        var isInitialized = false
        var assets: [NftAsset] = []
    }

    struct Environment {
        let mainQueue: AnySchedulerOf<DispatchQueue>
        let backgroundQueue: AnySchedulerOf<DispatchQueue>
    }
}
