import Testing

class LocalFeedLoader {
  private let store: FeedStore
  init(store: FeedStore) {
    self.store = store
  }
}

class FeedStore {
  var deleteCachedFeedCallCount = 0
}

@Suite
struct CacheFeedUseCaseTests {
  @Test func testInitDoesNotDeleteCacheUponCreation() async throws {
    let store = FeedStore()
    _ = LocalFeedLoader(store: store)
    #expect(store.deleteCachedFeedCallCount == 0)
  }
}
