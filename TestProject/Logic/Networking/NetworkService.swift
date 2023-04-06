import Foundation
import Combine

public protocol NetworkService {
    func fetchUsers(at page: Int) -> AnyPublisher<UsersListResponse, Error>
}

class NetworkServiceImpl {
    private let session = URLSession(configuration: .default)
    let baseURL: String
    let decoder = JSONDecoder()
    
    init(baseURL: String) {
        self.baseURL = baseURL
    }
}

extension NetworkServiceImpl: NetworkService {
    func fetchUsers(at page: Int) -> AnyPublisher<UsersListResponse, Error> {
        let request = makeRequest(UsersListRequest(page: page))
        return session.dataTaskPublisher(for: request)
            .map { response in
                return response.data
            }
            .decode(type: UsersListResponse.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
}

extension NetworkServiceImpl {
    func makeRequest(_ endpoint: Endpoint) -> URLRequest {
        let url = URL(string: baseURL + endpoint.path)!
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        
        return request
    }
}
