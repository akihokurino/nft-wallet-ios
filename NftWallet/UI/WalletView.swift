import ComposableArchitecture
import SwiftUI
import web3swift

struct WalletView: View {
    let store: Store<WalletVM.State, WalletVM.Action>

    var body: some View {
        WithViewStore(store) { viewStore in
            List {
                VStack(alignment: .leading) {
                    Button(action: {}) {
                        Text("アドレス: \n\(viewStore.state.address.address)")
                            .lineLimit(nil)
                    }
                    Spacer().frame(height: 20)
                    Text("\(viewStore.state.balance) Ether")
                        .frame(
                            minWidth: 0,
                            maxWidth: .infinity,
                            minHeight: 100,
                            maxHeight: 100,
                            alignment: .center
                        )
                        .background(Color.green)
                        .foregroundColor(Color.white)
                        .cornerRadius(5.0)
                        .font(.largeTitle)
                }
                .padding()
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
            }
            .listStyle(PlainListStyle())
            .navigationBarTitle("ウォレット", displayMode: .inline)
            .onAppear {
                viewStore.send(.startInitialize)
            }
            .overlay(
                Group {
                    if viewStore.state.shouldShowHUD {
                        HUD(isLoading: viewStore.binding(
                            get: \.shouldShowHUD,
                            send: WalletVM.Action.shouldShowHUD
                        ))
                    }
                }, alignment: .center
            )
            .refreshable {
                viewStore.send(.startRefresh)
                try! await Task.sleep(nanoseconds: 2000000000)
            }
        }
    }
}
