import Combine
import FirebaseFunctions
import Foundation

struct IPFS {
    let hash: String
    let url: String
}

class CloudFunctionManager {
    static let shared = CloudFunctionManager()

    private init() {}

    let functions = Functions.functions(region: "asia-northeast1")

    func uploadNftMetadata(path: String, name: String, description: String, externalUrl: String) -> Future<IPFS, AppError> {
        return Future<IPFS, AppError> { promise in
            self.functions.httpsCallable("uploadNftMetadata").call([
                "path": path,
                "name": name,
                "description": description,
                "externalUrl": externalUrl
            ]) { result, error in
                guard error == nil else {
                    promise(.failure(AppError.plain(error!.localizedDescription)))
                    return
                }

                if let data = result?.data as? [String: Any] {
                    let hash = data["hash"] as? String ?? ""
                    let url = data["url"] as? String ?? ""
                    
                    print("ipfs hash: \(hash)")
                    print("ipfs url: \(url)")
                    
                    promise(.success(IPFS(hash: hash, url: url)))
                } else {
                    promise(.failure(AppError.defaultError()))
                }
            }
        }
    }
}
