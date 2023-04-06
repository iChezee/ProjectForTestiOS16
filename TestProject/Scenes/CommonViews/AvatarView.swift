import SwiftUI

struct AvatarView: View {
    @DefaultServiceManager var serviceManager
    
    let user: User
    var isTransitionAllowed: Bool = false
    let onFavouriteTap: (() -> Void)?
    
    init(user: User, onFavouriteTap: (() -> Void)? = nil) {
        self.user = user
        self.onFavouriteTap = onFavouriteTap
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            image
            favouriteIcon
        }
    }
    
    var image: some View {
        let size = CGFloat.extraLarge2
        return AsyncImage(url: user.avatar) { $0.resizable() } placeholder: {
            Image.placeholder.resizable()
        }
        .frame(width: size, height: size)
        .cornerRadius(size / 2)
        .background {
            let borderSize = size + 1
            Color.border
                .frame(width: borderSize, height: borderSize)
                .cornerRadius(borderSize / 2)
        }
    }
    
    var favouriteIcon: some View {
        Image(serviceManager.localStorage.isFavourite(user) ? Images.favouriteSelected.rawValue : Images.favouriteUnselected.rawValue)
            .resizable()
            .frame(width: .mediumLarge, height: .mediumLarge)
            .cornerRadius(.mediumLarge / 2)
            .padding([.top, .trailing], .zero)
            .onTapGesture {
                onFavouriteTap?()
            }
    }
}
