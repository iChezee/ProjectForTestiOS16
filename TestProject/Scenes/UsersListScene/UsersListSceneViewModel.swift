import Foundation
import Combine
import SwiftUI

public class UsersListSceneViewModelImpl: ObservableObject {
    @Published public var users = [User]()
    @Published public var isLoading = true
    @Published public var isFiltered = false
    
    let networkService: NetworkService
    
    private var fetchedUsers: Set<User> = [] {
        didSet {
            sortedUsers = isFiltered ? filteredUsers() : Array(fetchedUsers)
        }
    }
    private var sortedUsers = [User]() {
        didSet {
            users = sortedUsers.sorted(by: { $0.id < $1.id })
        }
    }
    private var currentPage = 1
    private var totalPages = 0
    private var totalUsers = 0
    
    private let localStorage: LocalStorage
    private var cancellables = Set<AnyCancellable>()
    
    init(networkService: NetworkService, localStorage: LocalStorage) {
        self.networkService = networkService
        self.localStorage = localStorage
        fetchUsers()
    }
    
    public func fetchUsers() {
        isLoading = true
        networkService.fetchUsers(at: currentPage)
            .receive(on: DispatchQueue.main)
            .sink { _ in } receiveValue: { [weak self] response in
                self?.saveDataFrom(response)
                self?.isLoading = false
            }
            .store(in: &cancellables)
    }
    
    func saveDataFrom(_ response: UsersListResponse) {
        saveUsers(response.users)
        totalPages = response.totalPages
        totalUsers = response.total
    }
    
    func saveUsers(_ users: [User]) {
        for user in users {
            var user = user
            user.isFavourite = localStorage.isFavourite(user)
            fetchedUsers.insert(user)
        }
    }
    
    func filteredUsers() -> [User] {
        fetchedUsers.filter { $0.isFavourite }
    }
    
    public func favouriteClicked(_ user: User) {
        fetchedUsers.forEach { fetchedUser in
            if fetchedUser.id == user.id {
                var user = user
                user.isFavourite.toggle()
                fetchedUsers.remove(fetchedUser)
                fetchedUsers.update(with: user)
            }
        }
        localStorage.toogleFavourite(user)
    }
    
    public func filterClicked() {
        isFiltered.toggle()
        sortedUsers = isFiltered ? filteredUsers() : Array(fetchedUsers)
    }
    
    public func refresh() {
        currentPage = 1
        fetchedUsers.removeAll()
        fetchUsers()
    }
    
    public func loadNext() {
        if totalPages < currentPage || fetchedUsers.count < totalUsers {
            currentPage += 1
            fetchUsers()
        }
    }
}
