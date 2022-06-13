import Combine
import Foundation

extension CloudFunctionClient {
    func uploadIPFS() -> Future<String, AppError> {
        return Future<String, AppError> { promise in
            functions.httpsCallable("uploadIPFS").call([:]) { result, error in
                guard error == nil else {
                    promise(.failure(AppError.plain(error!.localizedDescription)))
                    return
                }

                if let data = result?.data as? [String: Any], let gateway = data["gateway"] as? String {
                    promise(.success(gateway))
                } else {
                    promise(.failure(AppError.defaultError()))
                }
            }
        }
    }
}
