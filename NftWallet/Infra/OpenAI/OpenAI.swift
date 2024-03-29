import Alamofire
import Combine
import Foundation
import SwiftUI

protocol OpenAIProtocol {
    associatedtype ResponseType

    var method: HTTPMethod { get }
    var baseURL: URL { get }
    var path: String { get }
    var headers: [String: String]? { get }
    var allowsConstrainedNetworkAccess: Bool { get }
}

extension OpenAIProtocol {
    var baseURL: URL {
        return URL(string: "https://api.openai.com")!
    }

    var headers: [String: String]? {
        return [
            "Authorization": "Bearer \(Env.openAIApiKey)",
            "Content-Type": "application/json"
        ]
    }

    var allowsConstrainedNetworkAccess: Bool {
        return true
    }
}

protocol OpenAIRequestProtocol: OpenAIProtocol, URLRequestConvertible {
    var parameters: Parameters? { get }
    var encoding: URLEncoding { get }
}

extension OpenAIRequestProtocol {
    var encoding: URLEncoding {
        return URLEncoding.default
    }

    func asURLRequest() throws -> URLRequest {
        var urlRequest = URLRequest(url: baseURL.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        urlRequest.allHTTPHeaderFields = headers
        urlRequest.timeoutInterval = TimeInterval(30)
        urlRequest.allowsConstrainedNetworkAccess = allowsConstrainedNetworkAccess
        
        if let params = parameters {
            urlRequest.httpBody = try! JSONSerialization.data(withJSONObject: params, options: [])
        }

        return urlRequest
    }
}

struct OpenAIClient {
    private static let successRange = 200 ..< 300
    private static let contentType = "application/json"

    static func publish<T, V>(_ request: T) -> Future<V, AppError>
        where T: OpenAIRequestProtocol, V: Codable, T.ResponseType == V
    {
        return Future { promise in
            let api = AF.request(request)
                .validate(statusCode: self.successRange)
                .validate(contentType: [self.contentType])
                .responseDecodable(of: V.self) { response in
                    switch response.result {
                    case let .success(result):
                        promise(.success(result))
                    case let .failure(error):
                        print("OpenAIエラー \(error.localizedDescription)")
                        promise(.failure(AppError.plain(error.errorDescription ?? "エラーが発生しました")))
                    }
                }
            api.resume()
        }
    }
}
