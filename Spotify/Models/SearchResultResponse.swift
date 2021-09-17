//
//  SearchResultResponse.swift
//  Spotify
//
//  Created by haju Kim on 2021/09/17.
//

import Foundation

struct SearchResultResponse: Codable {
    let albums: SearchAlbumResponse
    let artists: SearchArtistResponse
    let playlists: SearchPlaylistResponse
    let tracks: SearchTracksResponse
}

struct SearchArtistResponse: Codable {
    let items: [Artist]
}

struct SearchAlbumResponse: Codable {
    let items: [Album]
}

struct SearchPlaylistResponse: Codable {
    let items: [Playlist]
}

struct SearchTracksResponse: Codable {
    let items: [AudioTrack]
}
