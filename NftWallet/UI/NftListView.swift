import ComposableArchitecture
import SwiftUI

struct NftListView: View {
    let store: Store<NftListVM.State, NftListVM.Action>

    var body: some View {
        WithViewStore(store) { viewStore in
            List {
                ForEach(viewStore.state.assets, id: \.self) { asset in
                    Button(action: {
                        UIApplication.shared.open(URL(string: asset.data.permalink)!)
                    }) {
                        NftAssetView(asset: asset)
                    }
                    .listRowSeparator(.hidden)
                    .padding(.vertical, 10)
                }
            }
            .listStyle(PlainListStyle())
            .navigationBarTitle("NFT", displayMode: .inline)
            .onAppear {
                viewStore.send(.startInitialize)
            }
            .overlay(
                Group {
                    if viewStore.state.shouldShowHUD {
                        HUD(isLoading: viewStore.binding(
                            get: \.shouldShowHUD,
                            send: NftListVM.Action.shouldShowHUD
                        ))
                    }
                }, alignment: .center
            )
            .refreshable {
                viewStore.send(.startRefresh)
            }
        }
    }
}

struct NftAssetView: View {
    let asset: NftAsset

    var body: some View {
        VStack(alignment: .leading) {
            AsyncImage(url: URL(string: asset.data.image_url)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    ProgressView()
                        .frame(height: 60, alignment: .center)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            Spacer()
            HStack {
                Text(asset.data.name).font(.headline)
                Spacer()
                Text("スキーマ: \(asset.data.asset_contract.schema_name)").font(.caption)
            }
            HStack {
                Text(asset.data.description).font(.subheadline)
                Spacer()
                Text("シンボル: \(asset.data.asset_contract.symbol)").font(.caption)
            }
        }
    }
}
