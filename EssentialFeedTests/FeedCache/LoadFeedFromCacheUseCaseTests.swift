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

  func testLoadDeliversCachedImagesOnLessThanSevenDaysOldCache() {
    let feed = uniqueImageFeed()
    let fixedCurrentDate = Date()
    let lessThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
    let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })


    expect(sut, toCompleteWith: .success(feed.models), when: {
      store.completeRetrieval(with: feed.local, timestamp: lessThanSevenDaysOldTimestamp)
    })
  }

  func testLoadDeliversNoImagesOnSevenDaysOldCache() {
    let feed = uniqueImageFeed()
    let fixedCurrentDate = Date()
    let sevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7)
    let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })


    expect(sut, toCompleteWith: .success([]), when: {
      store.completeRetrieval(with: feed.local, timestamp: sevenDaysOldTimestamp)
    })
  }

  func testLoadDeliversNoImagesOnMoreThanSevenDaysOldCache() {
    let feed = uniqueImageFeed()
    let fixedCurrentDate = Date()
    let moreThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: -1)
    let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })


    expect(sut, toCompleteWith: .success([]), when: {
      store.completeRetrieval(with: feed.local, timestamp: moreThanSevenDaysOldTimestamp)
    })
  }

  func testLoadDeletesCacheOnRetrievalError() {
    let (sut, store) = makeSUT()

    sut.load { _ in }
    store.completeRetrieval(with: anyNSError())

    XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
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

  private func uniqueImage() -> FeedImage {
    return FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
  }

  private func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
    let models = [uniqueImage(), uniqueImage()]
    let local = models.map {
      LocalFeedImage(
        id: $0.id,
        description: $0.description,
        location: $0.location,
        url: $0.url
      )
    }

    return (models, local)
  }

  private func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
  }

  private func anyNSError() -> NSError {
    NSError(domain: "Any Error", code: 1)
  }
}

private extension Date {
  func adding(days: Int) -> Date {
    return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
  }

  func adding(seconds: TimeInterval) -> Date {
    return self + seconds
  }
}
