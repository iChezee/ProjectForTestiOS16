import SwiftUI

struct DetailsScene: View {
    @Environment(\.presentationMode) private var presentationMode
    @State var user: User
    var onFavouriteClick: () -> Void
    var onSimilarUserClick: () -> Void
    
    var body: some View {
        VStack(spacing: .medium) {
            AvatarView(user: user) {
                user.isFavourite.toggle()
                onFavouriteClick()
            }
            Text(user.fullName)
            Text(user.email)
            Button(action: onSimilarUserClick) {
                Text("Random user").font(.title).bold()
            }
            Spacer()
        }
        .foregroundColor(.label)
        .padding(.horizontal, .large)
        .padding(.top, .mediumLarge)
        .background(Color.background.ignoresSafeArea(.all, edges: .all))
    }
}
