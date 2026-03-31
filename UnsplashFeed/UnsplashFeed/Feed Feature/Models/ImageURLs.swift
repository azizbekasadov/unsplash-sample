//
//  ImageURLs.swift
//  UnsplashFeed
//
//  Created by Azizbek Asadov on 31.03.2026.
//

import Foundation

public struct ImageURLs: Equatable, Hashable {
    public let raw: URL
    public let full: URL
    public let regular: URL
    public let small: URL
    public let thumb: URL
    
    public init(raw: URL, full: URL, regular: URL, small: URL, thumb: URL) {
        self.raw = raw
        self.full = full
        self.regular = regular
        self.small = small
        self.thumb = thumb
    }
}
