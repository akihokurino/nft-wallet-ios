import Foundation
import SwiftUIPager

extension Page: Equatable, Hashable {
    public static func == (lhs: SwiftUIPager.Page, rhs: SwiftUIPager.Page) -> Bool {
        return lhs.index == rhs.index
    }

    public func hash(into hasher: inout Hasher) {}
}
