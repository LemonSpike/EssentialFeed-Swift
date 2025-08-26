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

    _ = await sut.load()

    #expect(client.requestedURLs == [url])
  }

  @Test func testLoadTwiceRequestsDataFromURLTwice() async throws {
    let url = URL(string: "https://a-given-url.com")!
    let (sut, client) = makeSUT(url: url)

    _ = await sut.load()
    _ = await sut.load()

    #expect(client.requestedURLs == [url, url])
  }

  @Test func testLoadDeliversErrorOnClientError() async throws {
    let (sut, client) = makeSUT()
    client.error = NSError(domain: "Test", code: 0)
    
    let result = await sut.load()

    if case let .failure(error) = result {
      #expect(error as? RemoteFeedLoader.Error == RemoteFeedLoader.Error.connectivity)
    } else {
      fatalError("Expected failure, got \(result) instead")
    }
  }

  // MARK: - Helpers
  private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
    let client = HTTPClientSpy()
    return (RemoteFeedLoader(url: url, client: client), client)
  }

  private class HTTPClientSpy: HTTPClient {
    var requestedURLs: [URL] = []
    var error: Error?

    func get(from url: URL) async -> Result<[FeedItem], Error> {
      requestedURLs.append(url)
      if let error {
        return .failure(error)
      }
      return .success([])
    }
  }
}
