//
//  SettingsModels.swift
//  Spotify
//
//  Created by haju Kim on 2021/09/09.
//

import Foundation

struct Section {
    let title: String
    let options: [Option]
}
struct Option {
    let title: String
    let handler: () -> Void
}
