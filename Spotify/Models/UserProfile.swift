//
//  UserProfile.swift
//  Spotify
//
//  Created by haju Kim on 2021/09/08.
//

import Foundation

struct UserProfile: Codable {
    let country: String
    let display_name: String
    let email: String
    let explicit_content: [String: Bool]
    let external_urls: [String: String]
    let id: String
    let product: String
    let images: [UserImage]
    
}
struct UserImage: Codable {
    let url: String
}
