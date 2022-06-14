import Combine
import ComposableArchitecture
import SDWebImage
import SDWebImageSwiftUI
import UIKit

enum UploadNftVM {
    static let reducer = Reducer<State, Action, Environment> { state, action, environment in
        switch action {
        case .register(let payload):
            if payload.name.isEmpty || payload.description.isEmpty {
                return .none
            }

            state.shouldShowHUD = true
            let id = UUID().uuidString
            let data = payload.image.jpegData(compressionQuality: 0.8)!
            return FirebaseStorageManager.shared.upload(data: data, path: "assets/\(id).jpeg")
                .flatMap { path in
                    CloudFunctionManager
                        .shared
                        .uploadNftMetadata(path: path,
                                           name: payload.name,
                                           description: payload.description,
                                           externalUrl: payload.externalUrl)
                }
                .subscribe(on: environment.backgroundQueue)
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(UploadNftVM.Action.registered)
        case .registered(.success(_)):
            state.shouldShowHUD = false
            return .none
        case .registered(.failure(let error)):
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

extension UploadNftVM {
    enum Action: Equatable {
        case register(RegisterNftPayload)
        case registered(Result<String, AppError>)
        case shouldShowHUD(Bool)
        case back
    }

    struct State: Equatable {
        let asset: ImageAsset

        var shouldShowHUD = false
    }

    struct Environment {
        let mainQueue: AnySchedulerOf<DispatchQueue>
        let backgroundQueue: AnySchedulerOf<DispatchQueue>
    }
}
