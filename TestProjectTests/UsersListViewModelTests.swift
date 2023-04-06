import XCTest
@testable import TestProject

class UsersListViewModelTests: XCTestCase {
    let viewModel = MockUsersListSceneViewModel()
    let defaultUserCount = 10
    
    override func setUp() {
        viewModel.eraseData()
    }
    
    func test_fetchMore_when_zeroUsers() throws {
        let response = UsersListResponse(page: 0, total: 0, totalPages: 0, users: [])
        viewModel.mockedResponse = response
        viewModel.fetchUsers()
        XCTAssert(viewModel.users.count == 0)
    }
    
    func test_fetchMore_when_finalPage() throws {
        let response = UsersListResponse(page: 1, total: defaultUserCount, totalPages: 1, users: mockUsers(till: defaultUserCount))
        viewModel.mockedResponse = response
        viewModel.fetchUsers()
        viewModel.loadNext()
        XCTAssert(viewModel.users.count == defaultUserCount)
    }
    
    func test_fetchMore_when_pagesLessThenUsers() throws {
        let response = UsersListResponse(page: 1, total: defaultUserCount * 2, totalPages: defaultUserCount * 1, users: mockUsers(till: defaultUserCount))
        viewModel.mockedResponse = response
        viewModel.fetchUsers()
        viewModel.loadNext()
        XCTAssert(viewModel.users.count == defaultUserCount)
    }
    
    func test_fetch_when_refresh() throws {
        let count = 10
        fetchBunchOfUsers(bunch: defaultUserCount, iterations: 2)
        XCTAssert(viewModel.users.count == count * 2)

        viewModel.refresh()
        XCTAssert(viewModel.users.count == count)
    }
    
    func fetchBunchOfUsers(bunch: Int, iterations: Int) {
        let max = Int.max
        viewModel.mockedResponse = UsersListResponse(page: 1, total: max, totalPages: max, users: mockUsers(till: bunch))
        viewModel.fetchUsers()
        for i in 1..<iterations {
            let users = mockUsers(from: i*bunch, till: i*bunch + bunch)
            viewModel.mockedResponse = UsersListResponse(page: i + 1, total: max, totalPages: max, users: users)
            viewModel.loadNext()
        }
    }
    
    func test_fetch_when_filterEnabled() throws {
        let favourited = 2
        let response = UsersListResponse(page: 1, total: 30, totalPages: 3, users: mockFavouritedUsers(favourited,
                                                                                                       total: defaultUserCount))
        viewModel.mockedResponse = response
        viewModel.isFiltered = true
        viewModel.fetchUsers()
        XCTAssert(viewModel.users.count == favourited)
    }
    
    func test_filterUsers_when_toogled() {
        let favourited = 2
        let total = 5
        let response = UsersListResponse(page: 1, total: 30, totalPages: 3, users: mockFavouritedUsers(favourited, total: total))
        viewModel.mockedResponse = response
        viewModel.fetchUsers()
        XCTAssert(viewModel.users.count == total)
        
        viewModel.filterClicked()
        XCTAssert(viewModel.isFiltered)
        XCTAssert(viewModel.users.count == favourited)
        
        viewModel.filterClicked()
        XCTAssert(!viewModel.isFiltered)
        XCTAssert(viewModel.users.count == total)
    }
    
    func test_favouriteUser_when_favouriteClicked() throws {
        let count = 5
        let response = UsersListResponse(users: mockUsers(till: 5))
        viewModel.mockedResponse = response
        viewModel.fetchUsers()
        
        let index = Int.random(in: 0..<count)
        var randomUser = viewModel.users[index]
        viewModel.favouriteClicked(randomUser)
        randomUser.isFavourite = true
        
        XCTAssert(viewModel.users[index].isFavourite == randomUser.isFavourite)
    }
}

extension UsersListViewModelTests {
    func mockUsers(from: Int = 0, till: Int) -> [User] {
        var users = [User]()
        for index in from..<till {
            let user = User(id: index)
            users.append(user)
        }
        return users
    }
    
    func mockFavouritedUsers(_ favourited: Int, total: Int) -> [User] {
        var users = [User]()
        for index in 0..<total {
            let user = User(id: index)
            if index < favourited {
                viewModel.favouriteClicked(user)
            }
            users.append(user)
        }
        return users
    }
}
