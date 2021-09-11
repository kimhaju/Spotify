//
//  Playlist.swift
//  Spotify
//
//  Created by haju Kim on 2021/09/08.
//

import Foundation

struct Playlist: Codable {
    let description: String
    let external_urls: [String: String]
    let id: String
    let images: [APIImage]
    let name: String
    let owner: User
}
