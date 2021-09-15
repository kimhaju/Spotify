//
//  AlbumDetailsResponse.swift
//  Spotify
//
//  Created by haju Kim on 2021/09/15.
//

import Foundation

/*
 모델 파일에 에러를 확인하면 하나씩 지워가면서 어디가 잘못되었는지 확인해 보는 방법이 느리지만 확실하다.
 */
struct AlbumDetailsResponse: Codable {
    let album_type: String
    let artists: [Artist]
    let available_markets: [String]
    let external_urls: [String: String]
    let id: String
    let images: [APIImage]
    let label: String
    let name: String
    let tracks: TracksResponse

}

struct TracksResponse: Codable {
    let items: [AudioTrack]
}

