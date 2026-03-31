//
//  RemoteFeedLoader.swift
//  UnsplashFeed
//
//  Created by Azizbek Asadov on 31.03.2026.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
    private let client: HTTPClient
    private let url: URL
    
    public enum Error: Swift.Error {
        case invalidData
        case connectivityIssue
    }
    
    public init(
        url: URL,
        client: HTTPClient
    ) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success(requestedData):
                completion(
                    RemoteFeedItemMapper.map(
                        requestedData.data,
                        for: requestedData.response
                    )
                )
            case let .failure(error):
                debugPrint(error.localizedDescription)
                completion(.failure(Error.connectivityIssue))
            }
        }
    }
}

