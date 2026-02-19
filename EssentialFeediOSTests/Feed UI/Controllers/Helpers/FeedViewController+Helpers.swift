import EssentialFeediOS
import UIKit
import XCTest

extension FeedViewController {
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
  
  func simulateUserInitiatedFeedReload() {
    refreshControl?.simulatePullToRefresh()
  }
  
  @discardableResult
  func simulateFeedImageViewVisible(at index: Int) -> FeedImageCell? {
    return feedImageView(at: index) as? FeedImageCell
  }

  @discardableResult
  func simulateFeedImageViewNotVisible(at row: Int) -> FeedImageCell? {
    let view = simulateFeedImageViewVisible(at: row)
    
    let delegate = tableView.delegate
    let index = IndexPath(row: row, section: feedImagesSection)
    delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)

    return view
  }

  func simulateFeedImageViewNearVisible(at row: Int) {
    let ds = tableView.prefetchDataSource
    let index = IndexPath(row: row, section: feedImagesSection)
    ds?.tableView(tableView, prefetchRowsAt: [index])
  }
  
  func simulateFeedImageViewNotNearVisible(at row: Int) {
    simulateFeedImageViewNearVisible(at: row)
    
    let ds = tableView.prefetchDataSource
    let index = IndexPath(row: row, section: feedImagesSection)
    ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
  }
  
  var isShowingLoadingIndicator: Bool {
    refreshControl?.isRefreshing == true
  }
  
  func numberOfRenderedFeedImageViews() -> Int {
    tableView.numberOfRows(inSection: feedImagesSection)
  }
  
  func feedImageView(at row: Int) -> UITableViewCell? {
    let ds = tableView.dataSource
    let index = IndexPath(row: row, section: feedImagesSection)
    return ds?.tableView(tableView, cellForRowAt: index)
  }
  
  private var feedImagesSection: Int {
    0
  }
}

extension UIRefreshControl {
  func simulatePullToRefresh() {
    allTargets.forEach { target in
      actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
        (target as NSObject).perform(Selector($0))
      }
    }
  }
}

extension FeedImageCell {
  func simulateRetryAction() {
    feedImageRetryButton.simulateTap()
  }
  
  var isShowingLocation: Bool {
    !locationContainer.isHidden
  }
  
  var isShowingImageLoadingIndicator: Bool {
    feedImageContainer.isShimmering
  }
  
  var isShowingRetryAction: Bool {
    !feedImageRetryButton.isHidden
  }
  
  var locationText: String? {
    locationLabel.text
  }
  
  var descriptionText: String? {
    descriptionLabel.text
  }
  
  var renderedImage: Data? {
    feedImageView.image?.pngData()
  }
}

extension UIButton {
  func simulateTap() {
    allTargets.forEach { target in
      actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach {
        (target as NSObject).perform(Selector($0))
      }
    }
  }
}

class FakeRefreshControl: UIRefreshControl {
  
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

extension UIImage {
  static func make(withColor color: UIColor) -> UIImage {
    let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
    let format = UIGraphicsImageRendererFormat()
    format.scale = 1

    return UIGraphicsImageRenderer(size: rect.size, format: format).image { rendererContext in
      color.setFill()
      rendererContext.fill(rect)
    }
  }
}
