//
//  URLSessionHTTPClient.swift
//  UnsplashFeed
//
//  Created by Azizbek Asadov on 31.03.2026.
//

import Foundation

public final class URLSessionClient: HTTPClient {
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
        session.dataTask(with: url) { [weak self] data, response, error in
            guard self != nil else { return }
            
            if let error {
                completion(.failure(error))
            } else if let data, let response = response as? HTTPURLResponse {
                completion(.success((data, response)))
            } else {
                completion(.failure(UnexpectedValuesRepresentationError.unknownError))
            }
        }
        .resume()
    }
    
    // MARK: - Implementationn Details
    
    private enum UnexpectedValuesRepresentationError: Error, CustomStringConvertible {
        case unknownError
        
        var description: String {
            switch self {
            case .unknownError:
                return "Unknown error in the values representation from the data in response"
            }
        }
    }
}
