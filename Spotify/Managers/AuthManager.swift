//
//  AuthManager.swift
//  Spotify
//
//  Created by haju Kim on 2021/09/08.
//

import Foundation
final class AuthManager {
    static let shared = AuthManager()
    
    private init() {}
    
    //->로그인 여부
    var isSignedIn: Bool {
        return false
    }
    //->새로 생성하는 토큰
    private var accessToken: String? {
        return nil
    }
    //->새로고침 토큰
    private var refreshToken: String? {
        return nil
    }
    //->토큰 만료 날짜
    private var tokenExpirationDate: Date? {
        return nil
    }
    private var shouldRefreshToken: Bool {
        return  false
    }
}
