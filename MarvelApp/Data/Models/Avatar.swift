//
//  Avatar.swift
//  MarvelApp
//
//  Selectable profile avatar shown on the "Choose your Avatar" screen.
//

import Foundation

struct Avatar: Codable, Identifiable, Hashable {
    let id: String
    let imageName: String   // Asset-catalog image name
}
