import Combine
import Firebase
import Foundation

class FirebaseAuthManager {
    static let shared = FirebaseAuthManager()

    private init() {}

    func isLogin() -> Bool {
        return Auth.auth().currentUser != nil
    }

    func signInAnonymously() -> Future<String, AppError> {
        return Future<String, AppError> { promise in
            if self.isLogin() {
                promise(.success(Auth.auth().currentUser!.uid))
                return
            }

            Auth.auth().signInAnonymously { authResult, error in
                guard error == nil else {
                    promise(.failure(.plain(error!.localizedDescription)))
                    return
                }

                guard let user = authResult?.user else {
                    promise(.failure(AppError.defaultError()))
                    return
                }

                promise(.success(user.uid))
            }
        }
    }
}
