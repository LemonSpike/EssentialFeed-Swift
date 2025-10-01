import EssentialFeed
import Foundation
import Testing

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
  
  func deleteCachedFeed() {
    deleteCachedFeedCallCount += 1
  }
}

@Suite
struct CacheFeedUseCaseTests {
  @Test func testInitDoesNotDeleteCacheUponCreation() async throws {
    let (_, store) = makeSUT()
    #expect(store.deleteCachedFeedCallCount == 0)
  }
  
  @Test func testSaveRequestsCacheDeletion() async throws {
    let (sut, store) = makeSUT()
    let items = [uniqueItem(), uniqueItem()]
    
    // when
    sut.save(feed: items)
    
    #expect(store.deleteCachedFeedCallCount == 1)
  }
  
  // MARK: - Helpers
  private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
    let store = FeedStore()
    let sut = LocalFeedLoader(store: store)
    return (sut, store)
  }
  
  func uniqueItem() -> FeedItem {
    return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
  }
  
  func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
  }
}
