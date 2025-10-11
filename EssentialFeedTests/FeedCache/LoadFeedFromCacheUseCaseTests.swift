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

    expect(sut, toCompleteWith: .failure(retrievalError), when: {
      store.completeRetrieval(with: retrievalError)
    })
  }

  func testLoadDeliversNoImagesOnEmptyCache() {
    let (sut, store) = makeSUT()

    expect(sut, toCompleteWith: .success([]), when: {
      store.completeRetrievalWithEmptyCache()
    })
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

  private func expect(
    _ sut: LocalFeedLoader,
    toCompleteWith expectedResult: LoadFeedResult,
    when action: () -> Void,
    file: StaticString = #file,
    line: UInt = #line
  ) {
    let expectation = expectation(description: "Wait for load completion")

    sut.load() { receivedResult in
      switch (receivedResult, expectedResult) {
        case let (.success(receivedImages), .success(expectedImages)):
          XCTAssertEqual(receivedImages, expectedImages, file: file, line: line)
        case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
          XCTAssertEqual(receivedError, expectedError, file: file, line: line)
        default:
          XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
      }
      expectation.fulfill()
    }

    action()
    wait(for: [expectation], timeout: 0.1)
  }

  private func anyNSError() -> NSError {
    NSError(domain: "Any Error", code: 1)
  }
}
