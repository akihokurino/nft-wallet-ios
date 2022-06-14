import Combine
import ComposableArchitecture
import SDWebImage
import SDWebImageSwiftUI
import UIKit

enum UploadNftVM {
    static let reducer = Reducer<State, Action, Environment> { state, action, _ in
        switch action {
        case .register(let image):
            state.shouldShowHUD = true
            let id = UUID().uuidString
            let data = image.jpegData(compressionQuality: 0.8)!
            return FirebaseStorageManager.shared.upload(data: data, path: "/assets/\(id).jpeg")
                .catchToEffect()
                .map(UploadNftVM.Action.registered)
        case .registered(.success(_)):
            state.shouldShowHUD = false
            return .none
        case .registered(.failure(_)):
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

extension UploadNftVM {
    enum Action: Equatable {
        case register(UIImage)
        case registered(Result<Int64, AppError>)
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
