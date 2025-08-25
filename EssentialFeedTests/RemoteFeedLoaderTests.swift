import Foundation
import Testing

class RemoteFeedLoader {

  private let client: HTTPClient

  init(client: HTTPClient) {
    self.client = client
  }

  func load() {
    client.get(from: URL(string: "https://a-url.com")!)
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
    let client = HTTPClientSpy()
    _ = RemoteFeedLoader(client: client)

    #expect(client.requestedURL == nil)
  }

  @Test func testLoadRequestsDataFromURL() async throws {
    let client = HTTPClientSpy()
    let sut = RemoteFeedLoader(client: client)

    sut.load()

    #expect(client.requestedURL != nil)
  }
}
