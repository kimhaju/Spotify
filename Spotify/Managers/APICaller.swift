//
//  APICaller.swift
//  Spotify
//
//  Created by haju Kim on 2021/09/08.
//

import Foundation

final class APICaller {
    static let shared = APICaller()
    
    private init() {}
    
    struct Constants {
        static let baseAPIURL = "https://api.spotify.com/v1"
    }
    enum APIError: Error {
        case failedTogetData
    }
    
    public func getCurrentUserProfile(completion: @escaping (Result<UserProfile, Error>) -> Void) {
        createRequest(
            with: URL(string: Constants.baseAPIURL + "/me"),
            type: .GET
        ) { baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest) {
                data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedTogetData))
                    return
                }
                
                do {
                    let result =  try JSONDecoder().decode(UserProfile.self, from: data)
                    completion(.success(result))
                }
                catch {
                    print("api 호출에서 문제 발생: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    // MARK: -private
    enum HTTPMethod: String {
        case GET
        case POST
    }
    
    private func createRequest(
        with url:URL?,
        type: HTTPMethod,
        completion: @escaping (URLRequest) ->Void
    ){
        AuthManager.shared.withVaildToken{ token in
            guard let apiURL = url else {
                return
            }
            var request = URLRequest(url: apiURL)
            request.setValue("Bearer \(token)",
                             forHTTPHeaderField: "Authorization")
            request.httpMethod = type.rawValue
            request.timeoutInterval = 30
            completion(request)
        }
    }
}
