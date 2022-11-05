import ComposableArchitecture
import SwiftUI

struct TextToImageView: View {
    let store: Store<TextToImageVM.State, TextToImageVM.Action>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            List {
                VStack(alignment: .leading) {
                    TextFieldView(value: viewStore.binding(
                        get: \.inputText,
                        send: TextToImageVM.Action.inputText
                    ), label: "生成用テキスト", keyboardType: .default)
                    Spacer().frame(height: 20)
                    ActionButton(text: "生成する", buttonType: .primary) {
                        viewStore.send(.startGenerate)
                    }
                }
                .padding()
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
            }
            .listStyle(PlainListStyle())
            .navigationBarTitle("", displayMode: .inline)
            .overlay(
                Group {
                    if viewStore.state.shouldShowHUD {
                        HUD(isLoading: viewStore.binding(
                            get: \.shouldShowHUD,
                            send: TextToImageVM.Action.shouldShowHUD
                        ))
                    }
                }, alignment: .center
            )
        }
    }
}
