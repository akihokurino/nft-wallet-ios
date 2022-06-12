import Combine
import Photos
import UIKit

final class PhotoAsset: ObservableObject {
    let id: String
    let asset: PHAsset
    let manager = PHImageManager.default()

    @Published var image: UIImage? = nil

    func request(with targetSize: CGSize, callback: @escaping (UIImage?) -> Void) {
        guard self.image == nil else {
            callback(self.image)
            return
        }

        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        DispatchQueue.global().async {
            self.manager.requestImage(
                for: self.asset,
                targetSize: targetSize,
                contentMode: .aspectFill,
                options: options
            ) { [weak self] image, _ in
                DispatchQueue.main.async {
                    self?.image = image
                    callback(image)
                }
            }
        }
    }

    func requestForCrop(with targetSize: CGSize, callback: @escaping (UIImage?) -> Void) {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        DispatchQueue.global().async {
            self.manager.requestImage(
                for: self.asset,
                targetSize: targetSize,
                contentMode: .aspectFill,
                options: options
            ) { image, _ in
                DispatchQueue.main.async {
                    callback(image)
                }
            }
        }
    }

    init(asset: PHAsset) {
        self.id = asset.localIdentifier
        self.asset = asset
    }
}

extension PhotoAsset: Identifiable, Hashable {
    static func == (lhs: PhotoAsset, rhs: PhotoAsset) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}

extension PHAsset: Identifiable {}
