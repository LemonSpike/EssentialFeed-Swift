import Foundation
import Testing

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

protocol HTTPClient {
  func get(from url: URL)
}

class HTTPClientSpy: HTTPClient {
  func get(from url: URL) {
    requestedURL = url
  }

  var requestedURL: URL?
}

struct RemoteFeedLoaderTests {
  @Test func testInitDoesNotRequestDataFromURL() async throws {
    let url = URL(string: "https://a-url.com")!
    let client = HTTPClientSpy()
    _ = RemoteFeedLoader(url: url, client: client)

    #expect(client.requestedURL == nil)
  }

  @Test func testLoadRequestsDataFromURL() async throws {
    let url = URL(string: "https://a-given-url.com")!
    let client = HTTPClientSpy()
    let sut = RemoteFeedLoader(url: url, client: client)

    sut.load()

    #expect(client.requestedURL == url)
  }
}
