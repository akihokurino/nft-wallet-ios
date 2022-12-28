import Alamofire
import Combine
import Foundation

class IPFSClient {
    private static let successRange = 200 ..< 300
    private static let contentType = "application/json"

    static func upload(data: Data, filename: String) -> Future<String, AppError> {
        return Future<String, AppError> { promise in
            let basicAuth = "\(Env["IPFS_KEY"]!):\(Env["IPFS_SECRET"]!)";
            
            let api = AF.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(data, withName: "file", fileName: filename, mimeType: "image/jpeg")
            }, to: "\(Env["IPFS_URL"]!)/api/v0/add", method: .post, headers: ["Authorization": "Basic \(basicAuth.data(using: .utf8)!.base64EncodedString())"])
                .validate(statusCode: self.successRange)
                .validate(contentType: [self.contentType])
                .responseDecodable(of: IPFSResponse.self) { response in
                    switch response.result {
                    case let .success(result):
                        promise(.success(result.Hash))
                    case let .failure(error):
                        promise(.failure(AppError.plain(error.errorDescription ?? "エラーが発生しました")))
                    }
                }
            api.resume()
        }
    }
}

struct IPFSResponse: Codable, Equatable {
    let Name: String
    let Hash: String
}
