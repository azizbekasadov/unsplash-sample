//
//  MemoryLeaksTracker.swift
//  UnsplashFeed
//
//  Created by Azizbek Asadov on 31.03.2026.
//

import XCTest
import Foundation

public extension XCTestCase {
    func trackMemoryLeaks(
        for entity: AnyObject,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        addTeardownBlock { [weak entity] in
            XCTAssertNil(entity, "\(String(describing: entity)) must have been deallocated", file: file, line: line)
        }
    }
}
