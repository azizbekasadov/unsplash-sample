//
//  UnsplashFeedAPIEndToEndTests.swift
//  UnsplashFeed
//
//  Created by Azizbek Asadov on 05.04.2026.
//

import XCTest
import UnsplashFeed

final class UnsplashFeedAPIEndToEndTests: XCTestCase {
    
    func test_endToEndTestServerGETFeedResult_matchesFixedTestAccountData() {
        switch getFeedResult() {
        case let .success(items)?:
            XCTAssertEqual(items.count, 2, "Expected 2 items in the test account feed")
            
            items.enumerated().forEach { index, item in
                XCTAssertEqual(item, expectedItem(at: index), "Expected item \(item) is not valid at index: \(index)")
            }
            
        case let .failure(error)?:
            XCTFail("Expected success result on the request, got \(error) instead")
            
        default:
            XCTFail("Expected success result on the request, got no result instead")
        }
    }
    
    // MARK: - Helpers
    
    private func getFeedResult(file: StaticString = #filePath, line: UInt = #line) -> FeedLoader.Result? {
        let testServerURL = anyURL() // since the network requests will require a paid subscription, we are using here a mock server instead.
        URLProtocolStub.stub(
            data: makeFeedData(),
            response: HTTPURLResponse(
                url: testServerURL,
                statusCode: UnsplashFeedAPIEndToEndTests.OK,
                httpVersion: nil,
                headerFields: nil
            )!,
            error: nil,
            delay: 0.2
        )
        
        let session = makeInterceptedSession()
        let client = URLSessionClient(session: session)
        let loader = RemoteFeedLoader(url: testServerURL, client: client)
        
        trackMemoryLeaks(for: client, file: file, line: line)
        trackMemoryLeaks(for: loader, file: file, line: line)
        
        let exp = expectation(description: "Wait for completion")
        
        var receivedResult: FeedLoader.Result?
        loader.load { result in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        return receivedResult
    }
    
    private func expectedItem(at index: Int) -> FeedImage {
        FeedImage(
            id: id(at: index),
            description: description(at: index),
            altDescription: altDescription(at: index),
            createdAt: createdAt(at: index),
            width: width(at: index),
            height: height(at: index),
            colorHex: colorHex(at: index),
            blurHash: blurHash(at: index),
            urls: ImageURLs(
                raw: rawURL(at: index),
                full: fullURL(at: index),
                regular: regularURL(at: index),
                small: smallURL(at: index),
                thumb: thumbURL(at: index)
            ),
            links: PhotoLinks(
                html: htmlURL(at: index),
                download: downloadURL(at: index),
                downloadLocation: downloadLocationURL(at: index)
            ),
            author: AuthorSummary(
                id: authorID(at: index),
                username: username(at: index),
                name: authorName(at: index),
                portfolioURL: nil,
                bio: nil,
                location: nil,
                instagramUsername: nil,
                twitterUsername: nil,
                profileImage: nil,
                htmlURL: nil
            )
        )
    }
    
    private func id(at index: Int) -> String {
        [
            "31EC802C-F4EC-40AE-BE62-DA5F70892C72",
            "D222729D-EFA7-41EB-B997-13AC4F14C24F"
        ][index]
    }
    
    private static var OK: Int {
        return 200
    }
    
    private func description(at index: Int) -> String? {
        [
            nil,
            "a description"
        ][index]
    }
    
    private func altDescription(at index: Int) -> String? {
        [
            nil,
            "alt description"
        ][index]
    }
    
    private func createdAt(at index: Int) -> Date {
        ISO8601DateFormatter().date(from: [
            "2026-03-31T14:56:08Z",
            "2026-03-31T14:56:08Z"
        ][index])!
    }
    
    private func width(at index: Int) -> Int {
        [1, 1][index]
    }
    
    private func height(at index: Int) -> Int {
        [1, 1][index]
    }
    
    private func colorHex(at index: Int) -> String? {
        [nil, nil][index]
    }
    
    private func blurHash(at index: Int) -> String? {
        [nil, nil][index]
    }
    
    private func rawURL(at index: Int) -> URL {
        URL(string: [
            "http://a-url.com",
            "http://another-url.com"
        ][index])!
    }
    
    private func fullURL(at index: Int) -> URL {
        rawURL(at: index)
    }
    
    private func regularURL(at index: Int) -> URL {
        rawURL(at: index)
    }
    
    private func smallURL(at index: Int) -> URL {
        rawURL(at: index)
    }
    
    private func thumbURL(at index: Int) -> URL {
        rawURL(at: index)
    }
    
    private func htmlURL(at index: Int) -> URL {
        rawURL(at: index)
    }
    
    private func downloadURL(at index: Int) -> URL {
        rawURL(at: index)
    }
    
    private func downloadLocationURL(at index: Int) -> URL {
        rawURL(at: index)
    }
    
    private func authorID(at index: Int) -> String {
        [
            "C733EA41-6E4C-4900-920E-FC734BD88B36",
            "D0E8D005-679C-4609-9302-B9302D143BC7"
        ][index]
    }
    
    private func username(at index: Int) -> String {
        [
            "any username",
            "any username"
        ][index]
    }
    
    private func authorName(at index: Int) -> String {
        [
            "any name",
            "any name"
        ][index]
    }
    
    private func makeFeedData() -> Data {
        let bundle = Bundle(for: Self.self)
        let url = bundle.url(forResource: "feed", withExtension: "json")!
        
        return try! Data(contentsOf: url)
    }
    
    private func makeInterceptedSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        
        return URLSession(configuration: configuration)
    }
}

extension UnsplashFeedAPIEndToEndTests {
    private final class URLProtocolStub: URLProtocol {
        private static var stub: Stub?
        
        private struct Stub {
            let data: Data
            let response: URLResponse
            let error: Error?
            let delay: TimeInterval
        }
        
        override class func canInit(with request: URLRequest) -> Bool { true }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        static func stub(data: Data, response: URLResponse, error: Error?, delay: TimeInterval = 0) {
            stub = Stub(data: data, response: response, error: error, delay: delay)
        }
        
        static func removeStub() {
            stub = nil
        }
        
        override func startLoading() {
            guard let stub = URLProtocolStub.stub else {
                client?.urlProtocol(self, didFailWithError: anyNSError())
                return
            }
            
            let queue = DispatchQueue.global()
            queue.asyncAfter(deadline: .now() + stub.delay) { [weak self] in
                guard let self else { return }
                
                if let error = stub.error {
                    self.client?.urlProtocol(self, didFailWithError: error)
                } else {
                    self.client?.urlProtocol(self, didReceive: stub.response, cacheStoragePolicy: .allowedInMemoryOnly)
                    self.client?.urlProtocol(self, didLoad: stub.data)
                    self.client?.urlProtocolDidFinishLoading(self)
                }
            }
        }
        
        override func stopLoading() {}
    }
}
