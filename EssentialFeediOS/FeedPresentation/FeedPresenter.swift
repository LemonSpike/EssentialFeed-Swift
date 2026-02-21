import EssentialFeed
import Foundation

protocol FeedLoadingView {
  func display(_ viewModel: FeedLoadingViewModel)
}

protocol FeedView {
  func display(_ viewModel: FeedViewModel)
}

final class FeedPresenter {
  private let loadingView: FeedLoadingView
  private let feedView: FeedView
  
  init(loadingView: FeedLoadingView, feedView: FeedView) {
    self.loadingView = loadingView
    self.feedView = feedView
  }
  
  static var title: String {
    NSLocalizedString(
      "FEED_VIEW_TITLE",
      tableName: "Feed",
      bundle: Bundle(for: self.self),
      comment: "Title for the feed view"
    )
  }

  func didStartLoadingFeed() {
    guard Thread.isMainThread else {
      return DispatchQueue.main.async { [weak self] in self?.didStartLoadingFeed() }
    }

    loadingView.display(FeedLoadingViewModel(isLoading: true))
  }
  
  func didFinishLoadingFeed(with feed: [FeedImage]) {
    guard Thread.isMainThread else {
      return DispatchQueue.main.async { [weak self] in self?.didFinishLoadingFeed(with: feed) }
    }
    
    feedView.display(FeedViewModel(feed: feed))
    loadingView.display(FeedLoadingViewModel(isLoading: false))
  }
  
  func didFinishLoadingFeed(with error: Error) {
    guard Thread.isMainThread else {
      return DispatchQueue.main.async { [weak self] in self?.didFinishLoadingFeed(with: error) }
    }
    
    loadingView.display(FeedLoadingViewModel(isLoading: false))
  }
}
