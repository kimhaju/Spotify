//
//  AudioTrack.swift
//  Spotify
//
//  Created by haju Kim on 2021/09/08.
//

import Foundation

struct AudioTrack: Codable {
    var album: Album?
    let artists: [Artist]
    let available_markets: [String]
    let disc_number: Int
    let duration_ms: Int
    let explicit: Bool
    let external_urls: [String: String]
    let id: String
    let name: String
    //->미리듣기 url 추가 
    let preview_url: String?
}

