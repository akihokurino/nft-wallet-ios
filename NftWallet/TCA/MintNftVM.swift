import Combine
import ComposableArchitecture
import SDWebImage
import SDWebImageSwiftUI
import UIKit

enum MintNftVM {
    static let reducer = Reducer<State, Action, Environment> { state, action, environment in
        switch action {
        case .mint(let payload):
            if payload.name.isEmpty || payload.description.isEmpty {
                return .none
            }

            state.shouldShowHUD = true

            let id = UUID().uuidString
            let data = payload.image.jpegData(compressionQuality: 1.0)!

            return FirebaseStorageManager.shared.upload(data: data, path: "assets/\(id).jpeg")
                .flatMap { path in
                    CloudFunctionManager
                        .shared
                        .uploadNftMetadata(path: path,
                                           name: payload.name,
                                           description: payload.description,
                                           externalUrl: payload.externalUrl)
                }
                .flatMap { file in EthereumManager.shared.mint(file: file).map { _ in true } }
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
    let name: String
    let description: String
    let externalUrl: String
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
