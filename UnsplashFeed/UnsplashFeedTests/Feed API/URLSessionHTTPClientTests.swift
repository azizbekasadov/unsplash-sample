//
//  URLSessionHTTPClient.swift
//  UnsplashFeed
//
//  Created by Azizbek Asadov on 31.03.2026.
//

import XCTest
import Foundation
import UnsplashFeed

final class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getFromURL_failsOnRequestError() {
        URLProtocolStub.startInterceptingRequests()
        
        let url = anyURL()
        let expectedError = anyNSError()
        
        URLProtocolStub.stub(url, data: nil, response: nil, error: expectedError)
        
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for completion")
        
        sut.get(from: url) { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError.code, expectedError.code)
                XCTAssertEqual(receivedError.domain, expectedError.domain)
            default:
                XCTFail("Expected failure with \(expectedError), got result: \(result) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
        URLProtocolStub.stopInterceptingRequests()
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> URLSessionClient {
        URLSessionClient(session: .shared)
    }
    
    private final class URLProtocolStub: URLProtocol {
        private static var stubs = [URL: Stub]()
    
        private struct Stub {
            let data: Data?
            let response: HTTPURLResponse?
            let error: Error?
        }
        
        static func stub(
            _ url: URL,
            data: Data?,
            response: HTTPURLResponse?,
            error: Error?
        ) {
            stubs[url] = Stub(data: data, response: response, error: error)
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stubs = [:]
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            guard let url = request.url else {
                return false
            }
            
            return URLProtocolStub.stubs[url] != nil
        }
        
        override class func canonicalRequest(
            for request: URLRequest
        ) -> URLRequest { request }
        
        override func startLoading() {
            guard
                let url = request.url,
                let stub = URLProtocolStub.stubs[url]
            else { return }
            
            if let data = stub.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = stub.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
}
