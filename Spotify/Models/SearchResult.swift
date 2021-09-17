//
//  SearchResult.swift
//  Spotify
//
//  Created by haju Kim on 2021/09/17.
//

import Foundation

enum SearchResult {
    case artist(model: Artist)
    case album(model: Album)
    case track(model: AudioTrack)
    case playlist(model: Playlist)
}
