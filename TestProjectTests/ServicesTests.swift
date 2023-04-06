import XCTest
import Combine
@testable import TestProject

final class ServicesTests: XCTestCase {
    let localStorage: LocalStorage = LocalStorageImpl()
    let mockedUser = User(id: 0)
    
    var cancellables = Set<AnyCancellable>()
    
    override func setUp() {
        localStorage.eraseData()
    }
    
    func test_localStorage_when_user_favourited() throws {
        localStorage.toogleFavourite(mockedUser)
        assert(localStorage.isFavourite(mockedUser))
    }
    
    func test_localStorage_when_user_unfavourited() throws {
        localStorage.toogleFavourite(mockedUser)
        localStorage.toogleFavourite(mockedUser)
        assert(!localStorage.isFavourite(mockedUser))
    }
    
    func test_localStorage_when_user_not_favourited() throws {
        assert(!localStorage.isFavourite(mockedUser))
    }
}
