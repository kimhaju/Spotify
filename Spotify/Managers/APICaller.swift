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
        //->api get 주소가 다 이걸로 시작해서 공통 url로 사용하려고 이렇게 해놨음
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
    /// 새로운 릴리즈 
    public func getNewReleases(completion: @escaping ((Result<NewRealsesResponse, Error>)) -> Void){
        createRequest(with: URL(string: Constants.baseAPIURL + "/browse/new-releases?limit=50"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedTogetData))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(NewRealsesResponse.self, from: data)
                    completion(.success(result))
                }
                catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func getFeaturedPlayLists(completion: @escaping ((Result<FeaturedPlayListsResponse, Error>) -> Void)) {
        createRequest(
            with: URL(string: Constants.baseAPIURL + "/browse/featured-playlists?limit=20"),
            type: .GET
        ) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedTogetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(FeaturedPlayListsResponse.self, from: data)
                    completion(.success(result))
                }
                
                catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    //->자꾸 여기서 문제발생 왜?
    public func getRecommendations(genres: Set<String>, completion: @escaping ((Result<RecommendationsResponse, Error>)-> Void)) {
        let seeds = genres.joined(separator: ",")
        createRequest(with: URL(string: Constants.baseAPIURL + "/recommendations?limit=40&seed_genres=\(seeds)"),
                      type: .GET
        ) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedTogetData))
                    return
                }

                do {
                    let result = try JSONDecoder().decode(RecommendationsResponse.self, from: data)
                    completion(.success(result))
                }

                catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }

    //->추천 목록 가져오기 
    public func getRecommededGenres(completion: @escaping ((Result<RecommendedGenresResponse, Error>) -> Void)) {
        createRequest(
            with: URL(string: Constants.baseAPIURL + "/recommendations/available-genre-seeds"),
            type: .GET
        ) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedTogetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(RecommendedGenresResponse.self, from: data)
                    completion(.success(result))
                }
                
                catch {
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
