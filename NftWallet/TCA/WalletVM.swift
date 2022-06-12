import Combine
import ComposableArchitecture
import Foundation
import web3swift

enum WalletVM {
    static let reducer = Reducer<State, Action, Environment> { state, action, environment in
        switch action {
        case .startInitialize:
            guard !state.isInitialized else {
                return .none
            }

            state.shouldShowHUD = true

            let address = state.address
            
            return Future<String, AppError> { promise in
                DispatchQueue.global(qos: .background).async {
                    let web3 = web3(provider: Web3HttpProvider(URL(string: Env["CHAIN_URL"]!)!)!)

                    do {
                        let balanceWei = try web3.eth.getBalance(address: address)
                        let balanceEther = Web3.Utils.formatToEthereumUnits(balanceWei, toUnits: .eth, decimals: 3)!
                        promise(.success(balanceEther))
                    } catch {
                        promise(.failure(AppError.plain(error.localizedDescription)))
                    }
                }
            }
            .subscribe(on: environment.backgroundQueue)
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map(WalletVM.Action.endInitialize)
        case .endInitialize(.success(let balance)):
            state.balance = balance
            state.isInitialized = true
            state.shouldShowHUD = false
            return .none
        case .endInitialize(.failure(_)):
            state.shouldShowHUD = false
            return .none
        case .startRefresh:
            state.shouldPullToRefresh = true

            let address = state.address

            return Future<String, AppError> { promise in
                DispatchQueue.global(qos: .background).async {
                    let web3 = web3(provider: Web3HttpProvider(URL(string: Env["CHAIN_URL"]!)!)!)

                    do {
                        let balanceWei = try web3.eth.getBalance(address: address)
                        let balanceEther = Web3.Utils.formatToEthereumUnits(balanceWei, toUnits: .eth, decimals: 3)!
                        promise(.success(balanceEther))
                    } catch {
                        promise(.failure(AppError.plain(error.localizedDescription)))
                    }
                }
            }
            .subscribe(on: environment.backgroundQueue)
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map(WalletVM.Action.endRefresh)
        case .endRefresh(.success(let balance)):
            state.balance = balance
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

extension WalletVM {
    enum Action: Equatable {
        case startInitialize
        case endInitialize(Result<String, AppError>)
        case startRefresh
        case endRefresh(Result<String, AppError>)
        case shouldShowHUD(Bool)
        case shouldPullToRefresh(Bool)
    }

    struct State: Equatable {
        let address: EthereumAddress

        var shouldShowHUD = false
        var shouldPullToRefresh = false
        var isInitialized = false
        var balance = ""
    }

    struct Environment {
        let mainQueue: AnySchedulerOf<DispatchQueue>
        let backgroundQueue: AnySchedulerOf<DispatchQueue>
    }
}
