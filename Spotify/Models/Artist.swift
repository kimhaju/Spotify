//
//  Artist.swift
//  Spotify
//
//  Created by haju Kim on 2021/09/08.
//

import Foundation

struct Artist: Codable {
    let id: String
    let name: String
    let type: String
    let images: [APIImage]?
    let external_urls: [String: String]
}

