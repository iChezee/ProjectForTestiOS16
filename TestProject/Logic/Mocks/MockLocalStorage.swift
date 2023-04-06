import Foundation

class MockLocalStorage: LocalStorage {
    private var favourited = Set<User>()
    
    func isFavourite(_ user: User) -> Bool {
        favourited.contains(user)
    }
    
    func toogleFavourite(_ user: User) {
        if favourited.contains(user) {
            favourited.remove(user)
        } else {
            favourited.insert(user)
        }
    }
    
    func eraseData() {
        favourited.removeAll()
    }
}
