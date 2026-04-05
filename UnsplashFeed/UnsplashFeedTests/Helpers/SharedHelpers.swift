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

func anyData() -> Data {
    Data("any bytes".utf8)
}

func anyHTTPResponse(with statusCode: Int = 200) -> HTTPURLResponse {
    HTTPURLResponse(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
}

func anyURLResponse() -> URLResponse {
    URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
}
