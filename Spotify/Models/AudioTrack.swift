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
    //->실제 음원을 추가하고 싶었는데 저작권 문제로 오디오 트랙에서 실제 음악링크를 넣을 수 없는 것이 확인되었다. 그래서 테스트를 위해서 미리듣기 추가 
    let preview_url: String?
}

