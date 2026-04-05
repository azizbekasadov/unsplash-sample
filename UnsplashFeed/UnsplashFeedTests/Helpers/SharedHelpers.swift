//
//  SharedHelpers.swift
//  UnsplashFeed
//
//  Created by Azizbek Asadov on 31.03.2026.
//

import Foundation

public func anyURL() -> URL {
    URL(string: "https://a-url.com")!
}

public func anyNSError() -> NSError {
    NSError(domain: "any error", code: -1)
}

public func anyData() -> Data {
    Data("any bytes".utf8)
}

public func anyHTTPResponse(with statusCode: Int = 200) -> HTTPURLResponse {
    HTTPURLResponse(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
}

public func anyURLResponse() -> URLResponse {
    URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
}
