import SwiftUI

struct UsersListScene: View {
    @ObservedObject private var viewModel: UsersListSceneViewModelImpl
    @State private var path = NavigationPath()
    
    @State private var verticalOffset: CGFloat = 0.0
    @State private var totalHeight: CGFloat = 1000
    
    init(serviceManage: ServiceManager) {
        self.viewModel = UsersListSceneViewModelImpl(networkService: serviceManage.networkService,
                                                     localStorage: serviceManage.localStorage)
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            internalScrollView
                .navigationDestination(for: User.self) { user in
                    DetailsScene(user: user) {
                        viewModel.favouriteClicked(user)
                    } onSimilarUserClick: {
                        let randomUser = viewModel.users[Int.random(in: 0..<viewModel.users.count)]
                        path.append(randomUser)
                    }
                }
        }
    }
    
    private var internalScrollView: some View {
        ZStack(alignment: .topTrailing) {
            OffsettableScrollView { size in
                totalHeight = size.height
            } onOffsetChanged: { point in
                verticalOffset = point.y
            } content: {
                scrollViewContent
            }
            .refreshable {
                viewModel.refresh()
            }
            .padding(.top, .extraSmall2)
            
            filterButton
                .padding(.trailing, .small)
        }
        .padding(.top, .large)
        .padding(.bottom, .medium)
        .background(Color.background)
        .onChange(of: verticalOffset) { newValue in
            fetchNextIfNeeded(newValue)
        }
        .ignoresSafeArea()
    }
    
    private var scrollViewContent: some View {
        VStack {
            if viewModel.isLoading && viewModel.users.count == 0 {
                loadingState
            } else if !viewModel.isLoading && viewModel.users.count == 0 {
                Text("There is no users")
                    .foregroundColor(.label)
            } else {
                loadedView
            }
        }
    }
    
    private var loadingState: some View {
        ForEach(0..<2) { index in
            Image.placeholder
                .resizable()
                .frame(width: .extraLarge2, height: .extraLarge2)
                .cornerRadius(.extraLarge2 / 2)
                .padding(.horizontal, .large)
                .padding(.bottom, .medium)
        }
    }
    
    private var loadedView: some View {
        ForEach(viewModel.users, id: \.id) { user in
            Button(action: {
                path.append(user)
            }, label: {
                AvatarView(user: user) {
                    viewModel.favouriteClicked(user)
                }
                .padding(.horizontal, .large)
                .padding(.bottom, .medium)
            })
        }
    }
    
    var filterButton: some View {
        Button(action: { viewModel.filterClicked() }) {
            ZStack {
                Color.foreground
                    .frame(width: .mediumLarge, height: .mediumLarge)
                    .cornerRadius(.medium / 2)
                Image(viewModel.isFiltered ? Images.appliedFilter.rawValue : Images.filter.rawValue)
                    .resizable()
                    .frame(width: .medium, height: .medium)
            }
        }
    }
    
    private func fetchNextIfNeeded(_ offset: CGFloat) {
        if offset + totalHeight < 200 && !viewModel.isLoading {
            viewModel.loadNext()
        }
    }
}
