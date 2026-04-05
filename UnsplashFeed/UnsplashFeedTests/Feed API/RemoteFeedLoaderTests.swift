//
//  RemoteFeedLoaderTests.swift
//  UnsplashFeedTests
//
//  Created by Azizbek Asadov on 31.03.2026.
//

import XCTest
import Foundation
import UnsplashFeed

final class RemoteFeedLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, completeWith: failure(.connectivityIssue)) {
            client.complete(with: anyNSError(), at: 0)
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let sampleStatusCodes = [199, 201, 300, 400, 500]
        
        sampleStatusCodes.enumerated().forEach { index, statusCode in
            expect(sut, completeWith: failure(.invalidData)) {
                client.complete(with: statusCode, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, completeWith: failure(.invalidData)) {
            client.complete(with: 200, data: Data("invalid json value".utf8))
        }
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        
        expect(sut, completeWith: .success([])) {
            client.complete(with: 200, data: Data("[]".utf8))
        }
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        
        let item1 = makeItem(
            id: UUID(),
            imageURL: URL(string: "http://a-url.com")!)
        
        let item2 = makeItem(
            id: UUID(),
            description: "a description",
            altDescription: "alt description",
            imageURL: URL(string: "http://another-url.com")!
        )
        
        let items = [item1.model, item2.model]
        
        expect(sut, completeWith: .success(items)) {
            let json = self.makeItemsJSON([item1.json, item2.json])
            client.complete(with: 200, data: json)
        }
    }
    
    func test_load_doesNotDeliverResultAfterSUT() {
        let url = anyURL()
        let client = HTTPClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)
        
        var capturedResults = [RemoteFeedLoader.Result]()
        sut?.load { capturedResults.append($0) }
        
        sut = nil
        client.complete(with: 200, data: makeItemsJSON([]))
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    // MARK: - Helper
    
    private func makeSUT(
        url: URL = URL(string: "https://a-url.com")!,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        
        trackMemoryLeaks(for: sut, file: file, line: line)
        trackMemoryLeaks(for: client, file: file, line: line)
        
        return (sut, client)
    }
    
    private final class HTTPClientSpy: HTTPClient {
        private typealias Message = (url: URL, completion: (HTTPClient.Result) -> Void)
        
        private var messages = [Message]()
        
        var requestedURLs: [URL] {
            messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: NSError, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(with statusCode: Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil
            )!
            
            messages[index].completion(.success((data, response)))
        }
    }
    
    private func expect(
        _ sut: RemoteFeedLoader,
        completeWith expectedResult: RemoteFeedLoader.Result,
        on action: @escaping (() -> Void),
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for load expectations")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedImages), .success(expectedImages)):
                zip(receivedImages, expectedImages).enumerated().forEach { index, pair in
                    let (expected, received) = pair

                    debugPrint("ITEM \(index)")
                    debugPrint("id:", expected.id == received.id)
                    debugPrint("description:", expected.description == received.description)
                    debugPrint("altDescription:", expected.altDescription == received.altDescription)
                    debugPrint("createdAt:", expected.createdAt == received.createdAt)
                    debugPrint("createdAt expected:", expected.createdAt.timeIntervalSince1970)
                    debugPrint("createdAt received:", received.createdAt.timeIntervalSince1970)
                    debugPrint("width:", expected.width == received.width)
                    debugPrint("height:", expected.height == received.height)
                    debugPrint("colorHex:", expected.colorHex == received.colorHex)
                    debugPrint("blurHash:", expected.blurHash == received.blurHash)
                    debugPrint("urls:", expected.urls == received.urls)
                    debugPrint("links:", expected.links == received.links)
                    debugPrint("author:", expected.author == received.author)
                }
                
                XCTAssertEqual(receivedImages, expectedImages, file: file, line: line)
            case let (.failure(receivedError as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result: \(expectedResult), but got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
        .failure(error)
    }
    private func makeItem(
        id: UUID,
        description: String? = nil,
        altDescription: String? = nil,
        createdAt: String = "2026-03-31T14:56:08Z",
        imageURL: URL
    ) -> (model: FeedImage, json: [String: Any]) {
        let createdAt = iso8601Formatter.date(from: createdAt)!

        let item = FeedImage(
            id: id.uuidString,
            description: description,
            altDescription: altDescription,
            createdAt: createdAt,
            width: 1,
            height: 1,
            colorHex: nil,
            blurHash: nil,
            urls: ImageURLs(
                raw: imageURL,
                full: imageURL,
                regular: imageURL,
                small: imageURL,
                thumb: imageURL
            ),
            links: PhotoLinks(
                html: imageURL,
                download: imageURL,
                downloadLocation: imageURL
            ),
            author: AuthorSummary(
                id: UUID().uuidString,
                username: "any username",
                name: "any name",
                portfolioURL: nil,
                bio: nil,
                location: nil,
                instagramUsername: nil,
                twitterUsername: nil,
                profileImage: nil,
                htmlURL: nil
            )
        )

        return (item, item.json)
    }
    
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        try! JSONSerialization.data(withJSONObject: items as NSArray)
    }
}

private let iso8601Formatter: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime]
    return formatter
}()

private extension FeedImage {
    var json: [String: Any] {
        var main: [String: Any] = [
            "id": id,
            "created_at": iso8601Formatter.string(from: createdAt),
            "width": width,
            "height": height,
            "urls": [
                "raw": urls.raw.absoluteString,
                "full": urls.full.absoluteString,
                "regular": urls.regular.absoluteString,
                "small": urls.small.absoluteString,
                "thumb": urls.thumb.absoluteString
            ],
            "links": [
                "html": links.html.absoluteString,
                "download": links.download.absoluteString,
                "download_location": links.downloadLocation.absoluteString
            ],
            "user": author.json
        ]
        
        if let description {
            main["description"] = description
        }
        
        if let altDescription {
            main["alt_description"] = altDescription
        }
        
        if let colorHex {
            main["color"] = colorHex
        }
        
        if let blurHash {
            main["blur_hash"] = blurHash
        }
        
        return main
    }
}

private extension AuthorSummary {
    var json: [String: Any] {
        var main: [String: Any] = [
            "id": id,
            "username": username,
            "name": name
        ]

        if let portfolioURL {
            main["portfolio_url"] = portfolioURL.absoluteString
        }

        if let bio {
            main["bio"] = bio
        }

        if let location {
            main["location"] = location
        }

        if let instagramUsername {
            main["instagram_username"] = instagramUsername
        }

        if let twitterUsername {
            main["twitter_username"] = twitterUsername
        }

        if let profileImage {
            main["profile_image"] = profileImage.json
        }

        if let htmlURL {
            main["links"] = ["html": htmlURL.absoluteString]
        }

        return main
    }
}

private func compact(_ dictionary: [String: Any?]) -> [String: Any] {
    dictionary.compactMapValues { $0 }
}

private extension ProfileImageURLs {
    var json: [String: Any] {
        [
            "small": small?.absoluteString ?? "",
            "medium": medium?.absoluteString ?? "",
            "large": large?.absoluteString ?? ""
        ].compactMapValues { $0 }
    }
}
