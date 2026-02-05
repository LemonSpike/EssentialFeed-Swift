import EssentialFeed
import Foundation

public struct FeedLoadingViewModel {
  let isLoading: Bool
}

protocol FeedLoadingView {
  func display(_ viewModel: FeedLoadingViewModel)
}

public struct FeedViewModel {
  let feed: [FeedImage]
}

protocol FeedView {
  func display(_ viewModel: FeedViewModel)
}

final class FeedPresenter {
  var loadingView: FeedLoadingView?
  var feedView: FeedView?

  func didStartLoadingFeed() {
    loadingView?.display(FeedLoadingViewModel(isLoading: true))
  }
  
  func didFinishLoadingFeed(with feed: [FeedImage]) {
    self?.feedView?.display(FeedViewModel(feed: feed))
    loadingView?.display(FeedLoadingViewModel(isLoading: false))
  }
  
  func didFinishLoadingFeed(with error: Error) {
    loadingView?.display(FeedLoadingViewModel(isLoading: false))
  }
}
