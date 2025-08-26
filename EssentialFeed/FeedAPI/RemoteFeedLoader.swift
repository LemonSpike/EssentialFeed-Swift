import Foundation

protocol HTTPClient {
  func get(from url: URL)
}

class RemoteFeedLoader {

  private let client: HTTPClient
  private let url: URL

  init(
    url: URL,
    client: HTTPClient
  ) {
    self.url = url
    self.client = client
  }

  func load() {
    client.get(from: url)
  }
}
