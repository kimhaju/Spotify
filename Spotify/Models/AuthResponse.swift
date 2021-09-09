//
//  AuthResponse.swift
//  Spotify
//
//  Created by haju Kim on 2021/09/09.
//

import Foundation

struct AuthResponse: Codable {
    let access_token: String
    let expires_in: Int
    let refresh_token: String?
    let scope: String
    let token_type: String
}
