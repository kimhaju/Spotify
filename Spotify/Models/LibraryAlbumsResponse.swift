//
//  LibraryAlbumsResponse.swift
//  Spotify
//
//  Created by haju Kim on 2021/09/25.
//

import Foundation

struct LibraryAlbumsResponse: Codable {
    let items: [SavedAlbum]
}

struct SavedAlbum: Codable {
    let added_at: String
    let album: Album
}
