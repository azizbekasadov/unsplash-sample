//
//  ProfileImageURLs.swift
//  UnsplashFeed
//
//  Created by Azizbek Asadov on 31.03.2026.
//

import Foundation

public struct ProfileImageURLs: Equatable, Hashable {
    public let small: URL?
    public let medium: URL?
    public let large: URL?
    
    public init(small: URL?, medium: URL?, large: URL?) {
        self.small = small
        self.medium = medium
        self.large = large
    }
}
