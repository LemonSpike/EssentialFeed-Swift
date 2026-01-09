import XCTest
@testable import Prototype

final class PrototypeTests: XCTestCase {

  func test_refreshControl() {
    let sut = FeedViewController()
    
    sut.simulateAppearance()
    XCTAssertEqual(sut.refreshControl?.isRefreshing, true)
    
    sut.refreshControl?.endRefreshing()
    sut.refreshControl?.sendActions(for: .valueChanged)
    XCTAssertEqual(sut.refreshControl?.isRefreshing, true)
    
    sut.refreshControl?.endRefreshing()
    sut.simulateAppearance()
    XCTAssertEqual(sut.refreshControl?.isRefreshing, false)
  }
}

private extension FeedViewController {
  func simulateAppearance() {
    if !isViewLoaded {
      loadViewIfNeeded()
      replaceRefreshControlWithFakeForiOS17Support()
    }
    
    beginAppearanceTransition(true, animated: false)
    endAppearanceTransition()
  }
  
  func replaceRefreshControlWithFakeForiOS17Support() {
    let fake = FakeRefreshControl()
    
    refreshControl?.allTargets.forEach { target in
      refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { action in
        fake.addTarget(target, action: Selector(action), for: .valueChanged)
      }
    }
    refreshControl = fake
  }
}

private class FakeRefreshControl: UIRefreshControl {
  
  private var _isRefreshing = false
  
  override var isRefreshing: Bool {
    _isRefreshing
  }
  
  override func beginRefreshing() {
    _isRefreshing = true
  }
  
  override func endRefreshing() {
    _isRefreshing = false
  }
}
