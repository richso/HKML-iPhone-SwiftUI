//
//  Masterpiece.swift
//  HkmlApp
//
//  Created by Richard So on 5/9/2023.
//

import Foundation
import SwiftUI

struct Masterpiece: Hashable, Codable, Identifiable {
    let id: Int
    let name: String
    let image: String
    let href: String
    let author: String
    let author_href: String
}

