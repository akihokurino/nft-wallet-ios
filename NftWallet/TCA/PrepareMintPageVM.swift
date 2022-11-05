import Combine
import ComposableArchitecture
import Foundation
import SwiftUIPager

enum PrepareMintPageVM {
    static let reducer = Reducer<State, Action, Environment> { state, action, _ in
        switch action {
        case .changePage(let index):
            state.currentPage = .withIndex(index)
            state.currentSelection = index
            return .none
        case .textToImageView(let action):
            switch action {
            case .showMintNftView(let asset):
                state.mintNftView = MintNftVM.State(asset: asset)
                state.isPresentedMintNftView = true
                return .none
            default:
                return .none
            }
        case .assetListView(let action):
            switch action {
            case .showMintNftView(let asset):
                state.mintNftView = MintNftVM.State(asset: asset)
                state.isPresentedMintNftView = true
                return .none
            default:
                return .none
            }
        case .isPresentedMintNftView(let val):
            state.isPresentedMintNftView = val
            return .none
        case .mintNftView(let action):
            switch action {
            case .mint:
                return .none
            case .minted(.success(_)):
                state.isPresentedMintNftView = false
                state.mintNftView = nil
                return .none
            case .minted(.failure(_)):
                return .none
            case .back:
                state.isPresentedMintNftView = false
                state.mintNftView = nil
                return .none
            case .shouldShowHUD:
                return .none
            }
        }
    }
    .connect(
        TextToImageVM.reducer,
        state: \.textToImageView,
        action: /PrepareMintPageVM.Action.textToImageView,
        environment: { _environment in
            TextToImageVM.Environment(
                mainQueue: _environment.mainQueue,
                backgroundQueue: _environment.backgroundQueue
            )
        }
    )
    .connect(
        AssetListVM.reducer,
        state: \.assetListView,
        action: /PrepareMintPageVM.Action.assetListView,
        environment: { _environment in
            AssetListVM.Environment(
                mainQueue: _environment.mainQueue,
                backgroundQueue: _environment.backgroundQueue
            )
        }
    )
    .connect(
        MintNftVM.reducer,
        state: \.mintNftView,
        action: /PrepareMintPageVM.Action.mintNftView,
        environment: { env in
            MintNftVM.Environment(
                mainQueue: env.mainQueue,
                backgroundQueue: env.backgroundQueue
            )
        }
    )
}

extension PrepareMintPageVM {
    enum Action: Equatable {
        case changePage(Int)
        case isPresentedMintNftView(Bool)

        case textToImageView(TextToImageVM.Action)
        case assetListView(AssetListVM.Action)
        case mintNftView(MintNftVM.Action)
    }

    struct State: Equatable {
        let pageIndexes = Array(0 ..< 2)

        var currentPage: Page = .withIndex(0)
        var currentSelection: Int = 0
        var isPresentedMintNftView = false

        var textToImageView: TextToImageVM.State?
        var assetListView: AssetListVM.State?
        var mintNftView: MintNftVM.State?
    }

    struct Environment {
        let mainQueue: AnySchedulerOf<DispatchQueue>
        let backgroundQueue: AnySchedulerOf<DispatchQueue>
    }
}
