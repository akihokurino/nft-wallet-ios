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

            return OpenAIClient.publish(
                ImagesGenerationsRequest(prompt: text)
            )
            .subscribe(on: environment.backgroundQueue)
            .receive(on: environment.mainQueue)
            .flatMap { URLDownloader.download(urlString: $0.data.first!.url) }
            .catchToEffect()
            .map(TextToImageVM.Action.endGenerate)
        case .endGenerate(.success(let data)):
            state.shouldShowHUD = false
            state.inputText = "Van Gogh Starry Night"
            return Effect(value: .showMintNftView(UIImage(data: data)!))
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
        case endGenerate(Result<Data, AppError>)
        case showMintNftView(UIImage)
        case inputText(String)
    }

    struct State: Equatable {
        var shouldShowHUD = false
        
        var inputText = "Van Gogh Starry Night"
    }

    struct Environment {
        let mainQueue: AnySchedulerOf<DispatchQueue>
        let backgroundQueue: AnySchedulerOf<DispatchQueue>
    }
}
