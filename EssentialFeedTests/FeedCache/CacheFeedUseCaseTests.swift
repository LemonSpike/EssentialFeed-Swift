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
    let store = FeedStore()
    _ = LocalFeedLoader(store: store)
    #expect(store.deleteCachedFeedCallCount == 0)
  }
  
  @Test func testSaveRequestsCacheDeletion() async throws {
    let store = FeedStore()
    let sut = LocalFeedLoader(store: store)
    let items = [uniqueItem(), uniqueItem()]
    
    // when
    sut.save(feed: items)
    
    #expect(store.deleteCachedFeedCallCount == 1)
  }
  
  // MARK: - Helpers
  func uniqueItem() -> FeedItem {
    return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
  }
  
  func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
  }
}
