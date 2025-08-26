import Foundation
import Testing
import EssentialFeed

struct RemoteFeedLoaderTests {
  @Test func testInitDoesNotRequestDataFromURL() async throws {
    let (_, client) = makeSUT()

    #expect(client.requestedURLs.isEmpty)
  }

  @Test func testLoadRequestsDataFromURL() async throws {
    let url = URL(string: "https://a-given-url.com")!
    let (sut, client) = makeSUT(url: url)

    sut.load()

    #expect(client.requestedURLs == [url])
  }

  @Test func testLoadTwiceRequestsDataFromURLTwice() async throws {
    let url = URL(string: "https://a-given-url.com")!
    let (sut, client) = makeSUT(url: url)

    sut.load()
    sut.load()

    #expect(client.requestedURLs == [url, url])
  }

  // MARK: - Helpers
  private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
    let client = HTTPClientSpy()
    return (RemoteFeedLoader(url: url, client: client), client)
  }

  private class HTTPClientSpy: HTTPClient {
    var requestedURLs: [URL] = []

    func get(from url: URL) {
      requestedURLs.append(url)
    }
  }
}
