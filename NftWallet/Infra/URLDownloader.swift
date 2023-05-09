import Combine
import Foundation

class URLDownloader {
    static func download(urlString: String) -> Future<Data, AppError> {
        return Future<Data, AppError> { promise in
            guard let url = URL(string: urlString) else {
                promise(.failure(AppError.plain("不正なURLです")))
                return
            }

            let task = URLSession.shared.dataTask(with: url) { data, _, error in
                if let error = error {
                    print("Error fetching data: \(error.localizedDescription)")
                    promise(.failure(AppError.plain(error.localizedDescription)))
                    return
                }

                guard let data = data else {
                    promise(.failure(AppError.plain("エラーが発生しました")))
                    return
                }

                promise(.success(data))
            }

            task.resume()
        }
    }
}
