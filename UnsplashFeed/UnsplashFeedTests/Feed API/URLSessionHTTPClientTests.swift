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
    
    override func setUp() {
        super.setUp()
        
        URLProtocolStub.startInterceptingRequests()
    }
    
    override func tearDown() {
        super.tearDown()
        
        URLProtocolStub.stopInterceptingRequests()
    }
    
    func test_getFromProvidedURL_performsGETHTTPRequestWithProvidedURL() {
        let providedURL = anyURL()
        
        let exp = self.expectation(description: "Wait for load completion")
        
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, providedURL)
            XCTAssertEqual(request.httpMethod, "GET")
            
            exp.fulfill()
        }
        
        makeSUT().get(
            from: providedURL,
            completion: { _ in }
        )
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromProvidedURL_failsOnRequestError() {
        let expectedError = anyNSError()
        let receivedError = resultError(for: nil, response: nil, error: anyNSError())
        
        XCTAssertEqual(receivedError?.code, expectedError.code)
        XCTAssertEqual(receivedError?.domain, expectedError.domain)
    }
    
    func test_getFromProvidedURL_failsOnAllInvalidRepresentationCases() {
        // No data and error cases
        XCTAssertNotNil(resultError(for: nil, response: nil, error: nil))
        XCTAssertNotNil(resultError(for: nil, response: anyURLResponse(), error: nil))
        
        // No response and error cases
        XCTAssertNotNil(resultError(for: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultError(for: anyData(), response: nil, error: anyNSError()))
        
        // No data cases
        XCTAssertNotNil(resultError(for: nil, response: anyURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultError(for: nil, response: anyHTTPResponse(), error: anyNSError()))
        
        // With Data, and Error but URL and HTTP response types
        XCTAssertNotNil(resultError(for: anyData(), response: anyURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultError(for: anyData(), response: anyHTTPResponse(), error: anyNSError()))
        
        // With data but not HTTP Response -> we need it instead of URLResponse
        XCTAssertNotNil(resultError(for: anyData(), response: anyURLResponse(), error: nil))
    }
    
    func test_getFromProvidedURL_succeedsOnHTTPURLResponseWithData() {
        let expectedData = anyData()
        let expectedResponse = anyHTTPResponse()
        
        let result = resultSuccessValues(for: expectedData, response: expectedResponse, error: nil)
        
        XCTAssertEqual(result?.data, expectedData, "Expected proper data from http response")
        XCTAssertEqual(result?.response.url, expectedResponse.url, "Expected proper provided url from http response")
        XCTAssertEqual(result?.response.statusCode, expectedResponse.statusCode, "Expected success status code from provided url from http response")
    }
    
    // Due to the Apple's implementation of the URLResponse,
    // we need to validate empty data in retrieved result
    func test_getFromProvidedURL_succeedsWithEmptyDataOnHTTPURLResponseWithNilData() {
        let emptyData = Data()
        let expectedResponse = anyHTTPResponse()
        
        let receivedValues = resultSuccessValues(response: expectedResponse)
        XCTAssertEqual(receivedValues?.data, emptyData)
        XCTAssertEqual(receivedValues?.response.url, expectedResponse.url)
        XCTAssertEqual(receivedValues?.response.statusCode, expectedResponse.statusCode)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> HTTPClient {
        let sut = URLSessionClient()
        trackMemoryLeaks(for: sut, file: file, line: line)
        return sut
    }
    
    private func resultSuccessValues(
        for data: Data? = nil,
        response: URLResponse? = nil,
        error: NSError? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (data: Data, response: HTTPURLResponse)? {
        let retrievedResult = result(for: data, response: response, error: error)
        
        switch retrievedResult {
        case let .success(values):
            return values // (data, response)
        default:
            XCTFail("Expected success case with proper values, got \(retrievedResult) instead", file: file, line: line)
            return nil
        }
    }
    
    private func resultError(
        for data: Data?,
        response: URLResponse?,
        error: NSError?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> NSError? {
        let retrievedResult = result(for: data, response: response, error: error)
        
        switch retrievedResult{
        case let .failure(error as NSError):
            return error
        default:
            XCTFail("Expected failure case with proper values, got \(retrievedResult) instead", file: file, line: line)
            return nil
        }
    }
    
    private func result(
        for data: Data?,
        response: URLResponse?,
        error: NSError?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> HTTPClient.Result {
        URLProtocolStub.stub(data: data, response: response, error: error)
        
        let sut = makeSUT(file: file, line: line)
        let expectation = expectation(description: "Wait for result completion")
        
        var result: HTTPClient.Result!
        
        sut.get(from: anyURL()) {
            result = $0
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        return result
    }
    
    // MARK: - Stubs, Spies, Mocks
    
    private final class URLProtocolStub: URLProtocol {
        typealias ObservedRequest = (URLRequest) -> Void
        
        private static var stub: Stub?
        private static var observedRequest: ObservedRequest?
    
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(
            data: Data?,
            response: URLResponse?,
            error: Error?
        ) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        static func observeRequests(observer: @escaping ObservedRequest) {
            observedRequest = observer
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            
            stub = nil
            observedRequest = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool { true }
        
        override class func canonicalRequest(
            for request: URLRequest
        ) -> URLRequest { request }
        
        override func startLoading() {
            if let requestObserver = URLProtocolStub.observedRequest {
                client?.urlProtocolDidFinishLoading(self)
                return requestObserver(request)
            }
            
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
}
