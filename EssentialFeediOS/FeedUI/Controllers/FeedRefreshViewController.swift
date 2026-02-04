import UIKit

public final class FeedRefreshViewController: NSObject, FeedLoadingView {
  public lazy var view = loadView()

  private let presenter: FeedPresenter

  init(presenter: FeedPresenter) {
    self.presenter = presenter
    super.init()
  }
  
  // MARK: - FeedLoadingView
  public func display(_ viewModel: FeedLoadingViewModel) {
    if viewModel.isLoading {
      view.beginRefreshing()
    } else {
      view.endRefreshing()
    }
  }
  
  @objc func refresh() {
    presenter.loadFeed()
  }
  
  private func loadView() -> UIRefreshControl {
    let view = UIRefreshControl()
    view.addTarget(self, action: #selector(refresh), for: .valueChanged)
    return view
  }
}
