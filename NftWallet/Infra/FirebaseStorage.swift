import Combine
import FirebaseStorage
import Foundation

class FirebaseStorageManager {
    static let shared = FirebaseStorageManager()
    
    private let bucketName = "gs://nft-wallet-4faff.appspot.com"
    
    private init() {}
    
    func upload(data: Data, path: String) -> Future<Int64, AppError> {
        return Future<Int64, AppError> { promise in
            let metadata = StorageMetadata()
            metadata.contentType = "jpeg"
            
            let ref = Storage.storage(url: self.bucketName).reference().child(path)
            
            ref.putData(data, metadata: metadata) { metadata, _ in
                guard let metadata = metadata else {
                    promise(.failure(AppError.defaultError()))
                    return
                }
                
                let size = metadata.size
                promise(.success(size))
            }
        }
    }
}
