import SwiftUI

struct RefreshableModifier: ViewModifier {
    let action: @Sendable() async -> Void

    func body(content: Content) -> some View {
        List {
            content
        }
        .refreshable(action: action)
    }
}

extension ScrollView {
    func refreshable(action: @escaping @Sendable() async -> Void) -> some View {
        modifier(RefreshableModifier(action: action))
    }
}
