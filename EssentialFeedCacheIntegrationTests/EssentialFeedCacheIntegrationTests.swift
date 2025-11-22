import EssentialFeed
import XCTest

final class EssentialFeedCacheIntegrationTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    setupEmptyStoreState()
  }
  
  override func tearDown() {
    super.tearDown()
    undoStoreSideEffects()
  }
  
  func testLoadDeliversNoItemsOnEmptyCache() {
    let sut = makeSUT()

    expect(sut, toLoad: [])
  }
  
  func testLoadDeliversItemsSavedOnASeparateInstance() {
    let sutToPerformSave = makeSUT()
    let sutToPerformLoad = makeSUT()
    let feed = uniqueImageFeed().models
    
    save(feed, with: sutToPerformSave)
    
    expect(sutToPerformLoad, toLoad: feed)
  }
  
  func testSaveOverwritesItemsSavedOnASeparateInstance() {
    let sutToPerformFirstSave = makeSUT()
    let sutToPerformLastSave = makeSUT()
    let sutToPerformLoad = makeSUT()
    let firstFeed = uniqueImageFeed().models
    let lastFeed = uniqueImageFeed().models
    
    save(firstFeed, with: sutToPerformFirstSave)
    save(lastFeed, with: sutToPerformLastSave)
    
    expect(sutToPerformLoad, toLoad: lastFeed)
  }
  
  // MARK: - Helpers
  private func makeSUT(
    file: StaticString = #file,
    line: UInt = #line
  ) -> LocalFeedLoader {
    let storeBundle = Bundle(for: CoreDataFeedStore.self)
    let storeURL = testSpecificStoreURL()
    let store = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
    let sut = LocalFeedLoader(store: store, currentDate: Date.init)
    trackForMemoryLeaks(store, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)
    return sut
  }
  
  func expect(
    _ sut: LocalFeedLoader,
    toLoad items: [FeedImage],
    file: StaticString = #file,
    line: UInt = #line
  ) {
    let expectation = expectation(description: "Wait for load completion")
    sut.load { result in
      switch result {
      case let .success(loadedItems):
        XCTAssertEqual(loadedItems, items, "Expected empty feed result", file: file, line: line)
      case let .failure(error):
        XCTFail("Expected successful feed result, got \(error) instead", file: file, line: line)
      @unknown default:
        XCTFail("Unexpected case", file: file, line: line)
      }
      
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 0.1)
  }
  
  private func save(
    _ items: [FeedImage],
    with sut: LocalFeedLoader,
    file: StaticString = #file,
    line: UInt = #line
  ) {
    let saveExpectation = expectation(description: "Wait for save completion")
    sut.save(items) { saveResult in
      if case let Result.failure(error) = saveResult {
        XCTFail(
          "Expected to save feed successfully, instead received error \(error.localizedDescription)",
          file: file,
          line: line
        )
      }
      saveExpectation.fulfill()
    }
    wait(for: [saveExpectation], timeout: 0.1)
  }
  
  private func setupEmptyStoreState() {
    deleteStoreArtifacts()
  }
  
  private func undoStoreSideEffects() {
    deleteStoreArtifacts()
  }
  
  private func deleteStoreArtifacts() {
    try? FileManager.default.removeItem(at: testSpecificStoreURL())
  }
  
  private func testSpecificStoreURL() -> URL {
    cachesDirectory().appendingPathComponent("\(Self.self).store")
  }
  
  private func cachesDirectory() -> URL {
    FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
  }
}
