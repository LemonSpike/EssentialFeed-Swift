import EssentialFeed
import Foundation
import XCTest

class LocalFeedLoader {
  private let store: FeedStore
  init(store: FeedStore) {
    self.store = store
  }
  
  func save(feed: [FeedItem]) {
    store.deleteCachedFeed()
  }
}

class FeedStore {
  var deleteCachedFeedCallCount = 0
  var insertFeedCallCount = 0
  
  func deleteCachedFeed() {
    deleteCachedFeedCallCount += 1
  }
  
  func completeDeletion(with error: Error, at index: Int = 0) {
    // Simulate completion with error
  }
}

final class CacheFeedUseCaseTests: XCTestCase {
  func testInitDoesNotDeleteCacheUponCreation() async throws {
    let (_, store) = makeSUT()
    XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
  }
  
  func testSaveRequestsCacheDeletion() async throws {
    let (sut, store) = makeSUT()
    let items = [uniqueItem(), uniqueItem()]
    
    // when
    sut.save(feed: items)
    
    XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
  }
  
  func testSaveDoesNotRequestCacheInsertionOnDeletionError() async throws {
    let (sut, store) = makeSUT()
    let items = [uniqueItem(), uniqueItem()]
    let deletionError = anyNSError()
    
    // when
    sut.save(feed: items)
    store.completeDeletion(with: deletionError)
    
    XCTAssertEqual(store.insertFeedCallCount, 0)
  }
  
  // MARK: - Helpers
  private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
    let store = FeedStore()
    let sut = LocalFeedLoader(store: store)
    trackForMemoryLeaks(store, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)

    return (sut, store)
  }

  private func uniqueItem() -> FeedItem {
    return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
  }
  
  private func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
  }
  
  private func anyNSError() -> NSError {
    NSError(domain: "Any Error", code: 1)
  }

}
