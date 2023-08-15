import Alamofire
import Foundation
import Combine

protocol OpenSeaProtocol {
    associatedtype ResponseType

    var method: HTTPMethod { get }
    var baseURL: URL { get }
    var path: String { get }
    var headers: [String: String]? { get }
    var allowsConstrainedNetworkAccess: Bool { get }
}

extension OpenSeaProtocol {
    var baseURL: URL {
        return URL(string: "https://testnets-api.opensea.io")!
    }

    var headers: [String: String]? {
        return nil
    }

    var allowsConstrainedNetworkAccess: Bool {
        return true
    }
}

protocol OpenSeaRequestProtocol: OpenSeaProtocol, URLRequestConvertible {
    var parameters: Parameters? { get }
    var encoding: URLEncoding { get }
}

extension OpenSeaRequestProtocol {
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
            urlRequest = try encoding.encode(urlRequest, with: params)
        }
        
        return urlRequest
    }
}

struct OpenSeaClient {
    private static let successRange = 200 ..< 300
    private static let contentType = "application/json"
    
    static func publish<T, V>(_ request: T) -> Future<V, AppError>
        where T: OpenSeaRequestProtocol, V: Codable, T.ResponseType == V
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
                        promise(.failure(AppError.plain(error.errorDescription ?? "エラーが発生しました")))
                    }
                }
            api.resume()
        }
    }
}
