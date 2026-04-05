//
//  SharedHelpers.swift
//  UnsplashFeed
//
//  Created by Azizbek Asadov on 31.03.2026.
//

import Foundation

func anyURL() -> URL {
    URL(string: "https://a-url.com")!
}

func anyNSError() -> NSError {
    NSError(domain: "any error", code: -1)
}
