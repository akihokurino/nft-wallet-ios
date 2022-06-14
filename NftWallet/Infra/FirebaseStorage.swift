import Combine
import FirebaseStorage
import Foundation

class FirebaseStorageManager {
    static let shared = FirebaseStorageManager()
    
    private let bucketName = "gs://nft-wallet-4faff.appspot.com"
    
    private init() {}
    
    func upload(data: Data, path: String) -> Future<String, AppError> {
        return Future<String, AppError> { promise in
            let metadata = StorageMetadata()
            metadata.contentType = "jpeg"
            
            let ref = Storage.storage(url: self.bucketName).reference().child(path)
            
            ref.putData(data, metadata: metadata) { _, error in
                guard error == nil else {
                    promise(.failure(AppError.plain(error!.localizedDescription)))
                    return
                }
                promise(.success(path))
            }
        }
    }
}
