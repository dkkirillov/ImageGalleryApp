//
//  Photo.swift
//  Unsplash
//
//  Created by Dimique on 21/01/2021.
//

import UIKit

struct Photo: Identifiable, Decodable, Hashable {
    var id: String
    var urls: [String: String]
}

struct SearchPhoto: Decodable {
    var results: [Photo]
}
