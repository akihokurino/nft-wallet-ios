import Alamofire
import BigInt
import Foundation
import web3swift

class TextToImageRequest: RinnaRequestProtocol {
    typealias ResponseType = TextToImageResponse
    
    let prompts: String
    let scale: Float
    
    init(text: String) {
        self.prompts = text
        self.scale = 7.5
    }
    
    var parameters: Parameters? {
        return [
            "prompts": prompts,
            "scale": scale,
        ]
    }

    var method: HTTPMethod {
        return .post
    }

    var path: String {
        return "/models/tti/v2"
    }

    var allowsConstrainedNetworkAccess: Bool {
        return false
    }
}

struct TextToImageResponse: Codable, Equatable {
    let image: String
}

