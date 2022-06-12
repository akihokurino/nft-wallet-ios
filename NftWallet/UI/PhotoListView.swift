import Combine
import ComposableArchitecture
import SwiftUI

struct PhotoListView: View {
    let store: Store<PhotoListVM.State, PhotoListVM.Action>

    private let gridItemLayout = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]

    static let thumbnailSize = UIScreen.main.bounds.size.width / 2

    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                LazyVGrid(columns: gridItemLayout, alignment: HorizontalAlignment.leading, spacing: 2) {
                    ForEach(viewStore.assets, id: \.self) { asset in
                        Button(action: {}) {
                            PhotoAssetView(asset: asset)
                                .frame(maxWidth: PhotoListView.thumbnailSize)
                                .frame(height: PhotoListView.thumbnailSize)
                        }
                    }
                }
            }
            .navigationBarTitle("カメラロール", displayMode: .inline)
            .onAppear {
                viewStore.send(.startInitialize)
            }
            .overlay(
                Group {
                    if viewStore.state.shouldShowHUD {
                        HUD(isLoading: viewStore.binding(
                            get: \.shouldShowHUD,
                            send: PhotoListVM.Action.shouldShowHUD
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

struct PhotoAssetView: View {
    @ObservedObject var asset: PhotoAsset
    @State var image: UIImage? = nil

    var body: some View {
        HStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: PhotoListView.thumbnailSize)
                    .frame(height: PhotoListView.thumbnailSize)
                    .clipped()

            } else {
                Color
                    .gray
                    .frame(width: PhotoListView.thumbnailSize)
                    .frame(height: PhotoListView.thumbnailSize)
            }
        }
        .onAppear {
            asset.request(with: CGSize(width: PhotoListView.thumbnailSize * 3, height: PhotoListView.thumbnailSize * 3)) { image in
                self.image = image
            }
        }
    }
}
