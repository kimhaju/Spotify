//
//  AuthManager.swift
//  Spotify
//
//  Created by haju Kim on 2021/09/08.
//

import Foundation
final class AuthManager {
    static let shared = AuthManager()
    
    private var refreshingToken = false
    
    struct Constants {
        //->914 주의해야할점: 만지다 보니까 실수로 토큰글자를 지우거나 빼먹은게 있었다.
        // 만지면서 조심하기
        static let clientID = "9e5c28f29f4f439d9c674c7ebe4ca888"
        static let clientSecret = "6a328b701d074925b10b409ee257df1a"
        static let tokenAPIURL = "https://accounts.spotify.com/api/token"
        static let redirectURI = "http://localhost:8888/callback/"
        //->약관은 이정도면 충분할거 같아서 이것만 추가 
        static let scopes = "user-read-private%20playlist-modify-public%20playlist-read-private%20playlist-modify-private%20user-follow-read%20user-library-modify%20user-library-read%20user-read-email"
        /*
         스코프에 추가한 항목
         플레이 리스트목록: playlist-modify-public
         플레이 리스트 읽기: playlist-read-private
         플레이 리스트 목록2: playlist-modify-private
         팔로우 하고 있는 목록 불러오기 : user-follow-read
         유저 개인 목록 리스트 : user-library-read
         유저 이메일: user-read-email
         */
    }
    
    private init() {}
    
    public var signInURL: URL? {
        let base = "https://accounts.spotify.com/authorize"
        let string = "\(base)?response_type=code&client_id=\(Constants.clientID)&scope=\(Constants.scopes)&redirect_uri=\(Constants.redirectURI)&show_dialog=TRUE"
        return URL(string: string)
    }
    
    //->로그인 여부
    var isSignedIn: Bool {
        return accessToken != nil
    }
    //->새로 생성하는 토큰
    private var accessToken: String? {
        return UserDefaults.standard.string(forKey: "access_token")
    }
    //->새로고침 토큰(필요한 이유: 일정 만료 시간이 되면 새 토큰이 필요함)
    private var refreshToken: String? {
        return UserDefaults.standard.string(forKey: "refresh_token")
    }
    //->토큰 만료 날짜
    private var tokenExpirationDate: Date? {
        return UserDefaults.standard.object(forKey: "expirationDate") as? Date
    }
    //->토큰은 꼭 새로 고침 해줘야 하므로 특정 시간이 지나면 새 토큰을 만들어서 반환하는 메서드
    private var shouldRefreshToken: Bool {
        guard let expirationDate = tokenExpirationDate else {
            return false
        }
        let currentDate = Date()
        let fiveMinutes: TimeInterval = 300
        return currentDate.addingTimeInterval(fiveMinutes) >= expirationDate
    }
    public func exchangeCodeForToken(
        code: String,
        completion: @escaping ((Bool) -> Void)
    ){
        // 토큰을 가져옴
        guard let url = URL(string: Constants.tokenAPIURL) else {
            return
        }
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type",
                         value: "authorization_code"),
            URLQueryItem(name: "code",
                         value: code),
            URLQueryItem(name: "redirect_uri",
                         value: Constants.redirectURI),
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded ", forHTTPHeaderField: "Content-Type")
        request.httpBody = components.query?.data(using: .utf8)
        
        let basicToken = Constants.clientID+":"+Constants.clientSecret
        let data = basicToken.data(using: .utf8)
        guard let base64String = data?.base64EncodedString() else {
            print("문자열 변경에 실패했습니다.")
            completion(false)
            return
        }
        //->여기 띄어쓰기 한칸 안했다고 제이슨 파일 생성 안되었음. 띄어쓰기 조심
        request.setValue("Basic \(base64String)",
                         forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let data = data,
                  error == nil else {
                completion(false)
                return
            }
            do {
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                self?.cacheToken(result: result)
                completion(true)
            }
            catch {
                print(error.localizedDescription)
                completion(false)
            }
        }
        task.resume()
    }
    private var onRefreshBlocks = [((String)->Void)]()
    
    //->토큰이 새로 생성되기 전에 만료되는 것을 방지
    /// api로 부터 토큰을 호출 
    public func withVaildToken(completion: @escaping (String) -> Void){
        guard !refreshingToken else {
            // append the completion 새로 고침이 완료되면 추가 할것.
            onRefreshBlocks.append(completion)
            return
        }
        
        if shouldRefreshToken {
            // refresh
            refreshIfNeeded { [weak self] success in
                if let token = self?.accessToken, success {
                    completion(token)
                }
            }
        }
        else if let token = accessToken {
            completion(token)
        }
    }
    
    public func refreshIfNeeded(completion: ((Bool) -> Void)?){
        guard !refreshingToken else {
            return
        }
        
        guard shouldRefreshToken else {
            completion?(true)
            return
        }
        
        guard let refreshToken = self.refreshToken else {
            return
        }
        
        // 새로 생성된 토큰
        
        guard let url = URL(string: Constants.tokenAPIURL) else {
            return
        }
        refreshingToken = true
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type",
                         value: "refresh_token"),
            URLQueryItem(name: "refresh_token",
                         value: refreshToken),
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded ", forHTTPHeaderField: "Content-Type")
        request.httpBody = components.query?.data(using: .utf8)
        
        let basicToken = Constants.clientID+":"+Constants.clientSecret
        let data = basicToken.data(using: .utf8)
        guard let base64String = data?.base64EncodedString() else {
            print("문자열 변경에 실패했습니다.")
            completion?(false)
            return
        }
        //->여기 띄어쓰기 한칸 안했다고 제이슨 파일 생성 안되었음. 띄어쓰기 조심
        request.setValue("Basic \(base64String)",
                         forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            self?.refreshingToken = false
            guard let data = data,
                  error == nil else {
                completion?(false)
                return
            }
            do {
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                self?.onRefreshBlocks.forEach { $0(result.access_token) }
                self?.onRefreshBlocks.removeAll()
                self?.cacheToken(result: result)
                completion?(true)
            }
            catch {
                print(error.localizedDescription)
                completion?(false)
            }
        }
        task.resume()
        
    }
    
    private func cacheToken(result: AuthResponse) {
        UserDefaults.standard.setValue(result.access_token,
                                       forKey: "access_token")
        
        if let refresh_token = result.refresh_token {
            UserDefaults.standard.setValue(refresh_token,
                                           forKey: "refresh_token")
        }
       
        UserDefaults.standard.setValue(Date().addingTimeInterval(TimeInterval(result.expires_in)),
                                       forKey: "expirationDate")
    }
    
    public func signOut(completion: (Bool) -> Void){
        
        UserDefaults.standard.setValue(nil,
                                       forKey: "access_token")
        UserDefaults.standard.setValue(nil,
                                       forKey: "refresh_token")
        UserDefaults.standard.setValue(nil,
                                       forKey: "expirationDate")
        
        completion(true)
        
    }
}
