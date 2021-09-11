//
//  NewReleaseResponse.swift
//  Spotify
//
//  Created by haju Kim on 2021/09/10.
//

import Foundation

struct NewRealsesResponse: Codable {
    let albums: AlbumsResponse
}

struct AlbumsResponse: Codable {
    let items : [Album]
}

struct Album: Codable {
    let album_type : String
    let available_markets : [String]
    let id: String
    let images: [APIImage]
    let name: String
    let release_date: String
    let total_tracks: Int
    let artists: [Artist]
}

