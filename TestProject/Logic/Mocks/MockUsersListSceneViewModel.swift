import Foundation

public class MockUsersListSceneViewModel: UsersListSceneViewModelImpl {
    public var mockedResponse: UsersListResponse = UsersListResponse()
    public var fetchedUsers: Set<User> = []
    
    private let localStorage: LocalStorage = MockLocalStorage()
    
    public init() {
        super.init(networkService: NetworkServiceImpl(baseURL: ""), localStorage: localStorage)
    }
    
    override public func fetchUsers() {
        saveDataFrom(mockedResponse)
        isLoading = false
    }
    
    public func eraseData() {
        localStorage.eraseData()
    }
}
