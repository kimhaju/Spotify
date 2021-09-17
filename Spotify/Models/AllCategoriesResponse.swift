//
//  AllCategoriesResponse.swift
//  Spotify
//
//  Created by haju Kim on 2021/09/17.
//

import Foundation

struct AllCategoreisResponse: Codable {
    let categories: Categories
}
struct  Categories: Codable {
    let items: [Category]
}

struct Category: Codable {
    let id: String
    let name: String
    let icons: [APIImage]
}
