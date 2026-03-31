//
//  PhotoLinks.swift
//  UnsplashFeed
//
//  Created by Azizbek Asadov on 31.03.2026.
//

import Foundation

public struct PhotoLinks: Equatable, Hashable {
    public let html: URL
    public let download: URL
    public let downloadLocation: URL
    
    public init(html: URL, download: URL, downloadLocation: URL) {
        self.html = html
        self.download = download
        self.downloadLocation = downloadLocation
    }
}
