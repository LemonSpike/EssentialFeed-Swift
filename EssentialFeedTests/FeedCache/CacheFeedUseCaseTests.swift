import EssentialFeed
import Foundation
import XCTest

class LocalFeedLoader {
  private let store: FeedStore
  init(store: FeedStore) {
    self.store = store
  }
  
  func save(_ items: [FeedItem]) {
    store.deleteCachedFeed { [unowned self] error in
      if error == nil {
        self.store.insert(items)
      }
    }
  }
}

class FeedStore {
  typealias DeletionCompletion = (Error?) -> Void
  
  var deleteCachedFeedCallCount = 0
  var insertFeedCallCount = 0
  
  private var deletionCompletions: [DeletionCompletion] = []
  
  func deleteCachedFeed(completion: @escaping DeletionCompletion) {
    deleteCachedFeedCallCount += 1
    deletionCompletions.append(completion)
  }
  
  func completeDeletion(with error: Error, at index: Int = 0) {
    deletionCompletions[index](error)
  }
  
  func completeDeletionSuccessfully(at index: Int = 0) {
    deletionCompletions[index](nil)
  }
  
  func insert(_ items: [FeedItem]) {
    insertFeedCallCount += 1
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
    sut.save(items)
    
    XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
  }
  
  func testSaveDoesNotRequestCacheInsertionOnDeletionError() async throws {
    let (sut, store) = makeSUT()
    let items = [uniqueItem(), uniqueItem()]
    let deletionError = anyNSError()
    
    // when
    sut.save(items)
    store.completeDeletion(with: deletionError)
    
    XCTAssertEqual(store.insertFeedCallCount, 0)
  }
  
  func testSaveRequestsNewCacheInsertionOnSuccessfulDeletion() async throws {
    let (sut, store) = makeSUT()
    let items = [uniqueItem(), uniqueItem()]
    
    sut.save(items)
    store.completeDeletionSuccessfully()
    
    XCTAssertEqual(store.insertFeedCallCount, 1)
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
