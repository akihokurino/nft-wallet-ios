import Combine
import FirebaseFunctions
import Foundation

class CloudFunctionManager {
    static let shared = CloudFunctionManager()

    private init() {}

    let functions = Functions.functions(region: "asia-northeast1")

    func uploadNftMetadata(path: String, name: String, description: String, externalUrl: String) -> Future<String, AppError> {
        return Future<String, AppError> { promise in
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

                if let data = result?.data as? [String: Any], let url = data["url"] as? String {
                    print(url)
                    promise(.success(url))
                } else {
                    promise(.failure(AppError.defaultError()))
                }
            }
        }
    }
}
