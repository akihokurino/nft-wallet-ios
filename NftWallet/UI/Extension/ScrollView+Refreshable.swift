import SwiftUI

struct RefreshableModifier: ViewModifier {
    let action: @Sendable() async -> Void

    func body(content: Content) -> some View {
        List {
            HStack {
                Spacer()
                content
                Spacer()
            }
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets())
        }
        .refreshable(action: action)
        .listStyle(PlainListStyle())
    }
}

extension ScrollView {
    func refreshable(action: @escaping @Sendable() async -> Void) -> some View {
        modifier(RefreshableModifier(action: action))
    }
}
