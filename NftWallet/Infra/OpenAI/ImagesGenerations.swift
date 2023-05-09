import Alamofire
import Foundation

class ImagesGenerationsRequest: OpenAIRequestProtocol {
    typealias ResponseType = ImagesGenerationsResponse
    
    let prompt: String
    let n: Int
    let size: String
    
    init(prompt: String) {
        self.prompt = prompt
        self.n = 1
        self.size = "512x512"
    }
    
    var parameters: Parameters? {
        return [
            "prompt": prompt,
            "n": n,
            "size": size
        ]
    }

    var method: HTTPMethod {
        return .post
    }

    var path: String {
        return "/v1/images/generations"
    }

    var allowsConstrainedNetworkAccess: Bool {
        return false
    }
}

struct ImagesGenerationsResponse: Codable, Equatable {
    let data: [ImageResponse]
}

struct ImageResponse: Codable, Equatable {
    let url: String
}

