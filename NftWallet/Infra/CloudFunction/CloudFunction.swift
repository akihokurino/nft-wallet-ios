import Foundation
import FirebaseFunctions

struct CloudFunctionClient {
    let functions = Functions.functions(region: "asia-northeast1")
}
