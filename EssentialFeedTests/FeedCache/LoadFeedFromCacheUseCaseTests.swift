import EssentialFeed
import XCTest

final class LoadFeedFromCacheUseCaseTests: XCTestCase {

  func testInitDoesNotMessageStoreUponCreation() throws {
    let (_, store) = makeSUT()
    XCTAssertEqual(store.receivedMessages, [])
  }

  func testLoadRequestsCacheRetrieval() {
    let (sut, store) = makeSUT()

    sut.load { _ in }
    XCTAssertEqual(store.receivedMessages, [.retrieve])
  }

  func testLoadFailsOnRetrievalError() {
    let (sut, store) = makeSUT()
    let retrievalError = anyNSError()
    let expectation = expectation(description: "Wait for load completion")

    var receivedError: Error?
    sut.load() { result in
      switch result {
        case let .failure(error):
          receivedError = error
        default:
          XCTFail("Expected failure, got \(result) instead on load")
      }
      expectation.fulfill()
    }

    store.completeRetrieval(with: retrievalError)
    wait(for: [expectation], timeout: 0.1)
    XCTAssertEqual(receivedError as? NSError, retrievalError)
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
