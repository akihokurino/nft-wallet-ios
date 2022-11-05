import Alamofire
import Combine
import ComposableArchitecture
import Foundation
import UIKit

enum TextToImageVM {
    static let reducer = Reducer<State, Action, Environment> { state, action, environment in
        switch action {
        case .shouldShowHUD(let val):
            state.shouldShowHUD = val
            return .none
        case .startGenerate:
            let text = state.inputText
            guard !state.shouldShowHUD, !text.isEmpty else {
                return .none
            }

            state.shouldShowHUD = true

            return RinnaClient.publish(
                TextToImageRequest(text: text)
            )
            .subscribe(on: environment.backgroundQueue)
            .receive(on: environment.mainQueue)
            .map { $0.image }
            .catchToEffect()
            .map(TextToImageVM.Action.endGenerate)
        case .endGenerate(.success(let base64)):
            state.shouldShowHUD = false
            guard let imageData = Data(
                base64Encoded: base64.replacingOccurrences(of: "data:image/png;base64,", with: ""),
                options: .ignoreUnknownCharacters) else {
                return .none
            }
            state.inputText = ""
            return Effect(value: .showMintNftView(UIImage(data: imageData)!))
        case .endGenerate(.failure(_)):
            state.shouldShowHUD = false
            return .none
        case .showMintNftView:
            return .none
        case .inputText(let text):
            state.inputText = text
            return .none
        }
    }
}

extension TextToImageVM {
    enum Action: Equatable {
        case shouldShowHUD(Bool)
        case startGenerate
        case endGenerate(Result<String, AppError>)
        case showMintNftView(UIImage)
        case inputText(String)
    }

    struct State: Equatable {
        var shouldShowHUD = false
        
        var inputText = ""
    }

    struct Environment {
        let mainQueue: AnySchedulerOf<DispatchQueue>
        let backgroundQueue: AnySchedulerOf<DispatchQueue>
    }
}
