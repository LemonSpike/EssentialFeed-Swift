import EssentialFeed
import XCTest

final class ValidateFeedCacheUseCaseTests: XCTestCase {
  
  func testInitDoesNotMessageStoreUponCreation() throws {
    let (_, store) = makeSUT()
    XCTAssertEqual(store.receivedMessages, [])
  }
  
  func testValidateCacheDeletesCacheOnRetrievalError() {
    let (sut, store) = makeSUT()

    sut.validateCache()
    store.completeRetrieval(with: anyNSError())

    XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
  }
  
  func testValidateCacheDoesNotDeleteCacheOnEmptyCache() {
    let (sut, store) = makeSUT()

    sut.validateCache()
    store.completeRetrievalWithEmptyCache()

    XCTAssertEqual(store.receivedMessages, [.retrieve])
  }

  // MARK: - Helpers
  private func makeSUT(
    currentDate: @escaping () -> Date = Date.init,
    file: StaticString = #file,
    line: UInt = #line
  ) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
    let store = FeedStoreSpy()
    let sut = LocalFeedLoader(store: store, currentDate: currentDate)
    trackForMemoryLeaks(store, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)

    return (sut, store)
  }
  
  private func anyNSError() -> NSError {
    NSError(domain: "Any Error", code: 1)
  }
}
