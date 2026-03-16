import EssentialFeed
import Foundation

protocol FeedLoadingView {
  func display(_ viewModel: FeedLoadingViewModel)
}

protocol FeedView {
  func display(_ viewModel: FeedViewModel)
}

protocol FeedErrorView {
  func display(_ viewModel: FeedErrorViewModel)
}

final class FeedPresenter {
  private let loadingView: FeedLoadingView
  private let feedView: FeedView
  private let errorView: FeedErrorView
  
  init(
    loadingView: FeedLoadingView,
    feedView: FeedView,
    errorView: FeedErrorView
  ) {
    self.loadingView = loadingView
    self.feedView = feedView
    self.errorView = errorView
  }
  
  static var title: String {
    NSLocalizedString(
      "FEED_VIEW_TITLE",
      tableName: "Feed",
      bundle: Bundle(for: self.self),
      comment: "Title for the feed view"
    )
  }
  
  private var feedLoadError: String {
    return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR",
                             tableName: "Feed",
                             bundle: Bundle(for: FeedPresenter.self),
                             comment: "Error message displayed when we can't load the image feed from the server")
  }

  func didStartLoadingFeed() {
    errorView.display(.noError)
    loadingView.display(FeedLoadingViewModel(isLoading: true))
  }
  
  func didFinishLoadingFeed(with feed: [FeedImage]) {
    feedView.display(FeedViewModel(feed: feed))
    loadingView.display(FeedLoadingViewModel(isLoading: false))
  }
  
  func didFinishLoadingFeed(with error: Error) {
    errorView.display(.error(message: feedLoadError))
    loadingView.display(FeedLoadingViewModel(isLoading: false))
  }
}
