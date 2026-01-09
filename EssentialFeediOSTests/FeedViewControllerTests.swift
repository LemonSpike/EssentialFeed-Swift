import XCTest

final class FeedViewController {
  private let loader: FeedViewControllerTests.LoaderSpy
  
  init(loader: FeedViewControllerTests.LoaderSpy) {
    self.loader = loader
  }
}

final class FeedViewControllerTests: XCTestCase {

  func test_init_doesNotLoadFeed() {
    let loader = LoaderSpy()
    _ = FeedViewController(loader: loader)
    
    XCTAssertEqual(loader.loadCallCount, 0)
  }
  
  final class LoaderSpy {
    private(set) var loadCallCount = 0
    
    func load() {
      loadCallCount += 1
    }
  }
}

