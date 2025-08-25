import Foundation
import Testing

class RemoteFeedLoader {
  func load() {
    HTTPClient.shared.requestedURL = URL(string: "https://a-url.com")
  }
}

class HTTPClient {
  static let shared = HTTPClient()

  private init() {}
  var requestedURL: URL?
}

struct RemoteFeedLoaderTests {
  @Test func testInitDoesNotRequestDataFromURL() async throws {
    let client = HTTPClient.shared
    _ = RemoteFeedLoader()

    #expect(client.requestedURL == nil)
  }

  @Test func testLoadRequestsDataFromURL() async throws {
    let client = HTTPClient.shared
    let sut = RemoteFeedLoader()

    sut.load()

    #expect(client.requestedURL != nil)
  }
}
