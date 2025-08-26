import Foundation

public protocol HTTPClient {
  func get(from url: URL) async -> Result<[FeedItem], Error>
}

public final class RemoteFeedLoader {

  private let url: URL
  private let client: HTTPClient

  public enum Error: Swift.Error {
    case connectivity
  }

  public init(
    url: URL,
    client: HTTPClient
  ) {
    self.url = url
    self.client = client
  }

  public func load() async -> Result<[FeedItem], Swift.Error> {
    let result = await client.get(from: url)

    switch result {
    case let .success(items):
      return .success(items)
    case .failure:
      return .failure(Error.connectivity)
    }
  }
}
