import Combine
import Photos
import UIKit

typealias PhotoAuthorizationStatus = PHAuthorizationStatus
typealias PhotosImageResponse = UIImage?

enum PhotosManager {
    static func requestAuthorization() -> Future<PhotoAuthorizationStatus, Never> {
        return Future<PhotoAuthorizationStatus, Never> { promise in
            PHPhotoLibrary.requestAuthorization { status in
                promise(.success(status))
            }
        }
    }

    static func fetchAssets() -> Future<[ImageAsset], Never> {
        return Future<[ImageAsset], Never> { promise in
            let fetchOptions = PHFetchOptions()
            fetchOptions.fetchLimit = 1000
            fetchOptions.sortDescriptors = [
                NSSortDescriptor(key: "creationDate", ascending: false)
            ]
            let fetchResult: PHFetchResult = PHAsset.fetchAssets(
                with: .image,
                options: fetchOptions
            )
            var assets = [ImageAsset]()
            fetchResult.enumerateObjects { asset, _, _ in
                assets.append(ImageAsset(asset: asset))
            }
            promise(.success(assets))
        }
    }

    static func requestImage(asset: ImageAsset, targetSize: CGSize) -> Future<PhotosImageResponse, Never> {
        return Future<UIImage?, Never> { promise in
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            PHImageManager
                .default().requestImage(
                    for: asset.asset,
                    targetSize: targetSize,
                    contentMode: .aspectFill,
                    options: options
                ) { image, _ in
                    promise(.success(image))
                }
        }
    }

    static func requestFullImage(asset: ImageAsset) -> Future<PhotosImageResponse, Never> {
        return Future<UIImage?, Never> { promise in
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            PHImageManager
                .default()
                .requestImage(
                    for: asset.asset,
                    targetSize: PHImageManagerMaximumSize,
                    contentMode: .aspectFill,
                    options: options
                ) { image, _ in
                    promise(.success(image))
                }
        }
    }
}
