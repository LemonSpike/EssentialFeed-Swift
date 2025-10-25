import EssentialFeed
import Foundation
import XCTest

extension FeedStoreSpecs where Self: XCTestCase {
  @discardableResult
  func insert(
    _ cache: (feed: [LocalFeedImage], timestamp: Date),
    to sut: FeedStore,
    file: StaticString = #file,
    line: UInt = #line
  ) -> Error? {
    let expectation = self.expectation(description: "Wait for cache insertion")
    var insertionError: Error?
    sut.insert(cache.feed, timestamp: cache.timestamp) { receivedInsertionError in
      insertionError = receivedInsertionError
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 0.1)
    return insertionError
  }
  
  @discardableResult
  func deleteCache(from sut: FeedStore) -> Error? {
    let exp = expectation(description: "Wait for cache deletion")
    var deletionError: Error?
    sut.deleteCachedFeed { receivedDeletionError in
      deletionError = receivedDeletionError
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
    return deletionError
  }
  
  func expect(
    _ sut: FeedStore,
    toRetrieve expectedResult: RetrieveCachedFeedResult,
    file: StaticString = #file,
    line: UInt = #line
  ) {
    let expectation = self.expectation(description: "Wait for cache retrieval")
    
    sut.retrieve { retrievedResult in
      switch (retrievedResult, expectedResult) {
      case (.empty, .empty),
        (.failure, .failure):
        break
      case let (.found(retrievedFeed, retrievedTimestamp), .found(expectedFeed, expectedTimestamp)):
        XCTAssertEqual(retrievedFeed, expectedFeed, file: file, line: line)
        XCTAssertEqual(retrievedTimestamp, expectedTimestamp, file: file, line: line)
      default:
        XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead", file: file, line: line)
      }
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 0.1)
  }
  
  func expect(
    _ sut: FeedStore,
    toRetrieveTwice expectedResult: RetrieveCachedFeedResult,
    file: StaticString = #file,
    line: UInt = #line
  ) {
    expect(sut, toRetrieve: expectedResult, file: file, line: line)
    expect(sut, toRetrieve: expectedResult, file: file, line: line)
  }
}
