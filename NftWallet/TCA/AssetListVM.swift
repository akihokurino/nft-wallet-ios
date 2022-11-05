import Combine
import ComposableArchitecture
import Foundation
import UIKit

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
            case .showMintNftView:
                return .none
        }
    }
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
        case showMintNftView(UIImage)
    }

    struct State: Equatable {
        var shouldShowHUD = false
        var shouldPullToRefresh = false
        var isInitialized = false
        var assets: [ImageAsset] = []
    }

    struct Environment {
        let mainQueue: AnySchedulerOf<DispatchQueue>
        let backgroundQueue: AnySchedulerOf<DispatchQueue>
    }
}
