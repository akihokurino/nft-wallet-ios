import Combine
import ComposableArchitecture
import SDWebImage
import SDWebImageSwiftUI
import UIKit

enum MintNftVM {
    static let reducer = Reducer<State, Action, Environment> { state, action, environment in
        switch action {
        case .mint(let payload):
            state.shouldShowHUD = true

            let name = "NWSample"
            let data = payload.image.jpegData(compressionQuality: 1.0)!
            return IPFSClient.upload(data: data, filename: name)
                .flatMap { hash in
                    let url = "\(Env["IPFS_GATEWAY"]!)/ipfs/\(hash)"
                    let data = try! JSONEncoder().encode(Metadata(name: name, image: url, description: "nft wallet sample token"))
                    return IPFSClient.upload(data: data, filename: name)
                }
                .flatMap { hash in
                    return EthereumManager.shared.mint(hash: hash).map { _ in true }
                }
                .subscribe(on: environment.backgroundQueue)
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(MintNftVM.Action.minted)
        case .minted(.success(_)):
            state.shouldShowHUD = false
            return .none
        case .minted(.failure(let error)):
            state.shouldShowHUD = false
            return .none
        case .shouldShowHUD(let val):
            state.shouldShowHUD = val
            return .none
        case .back:
            return .none
        }
    }
}

struct RegisterNftPayload: Equatable {
    let image: UIImage
}

extension MintNftVM {
    enum Action: Equatable {
        case mint(RegisterNftPayload)
        case minted(Result<Bool, AppError>)
        case shouldShowHUD(Bool)
        case back
    }

    struct State: Equatable {
        let asset: UIImage

        var shouldShowHUD = false
    }

    struct Environment {
        let mainQueue: AnySchedulerOf<DispatchQueue>
        let backgroundQueue: AnySchedulerOf<DispatchQueue>
    }
}
