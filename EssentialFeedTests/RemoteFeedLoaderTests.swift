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

    sut.load() { _ in }

    #expect(client.requestedURLs == [url])
  }

  @Test func testLoadTwiceRequestsDataFromURLTwice() async throws {
    let url = URL(string: "https://a-given-url.com")!
    let (sut, client) = makeSUT(url: url)

    sut.load() { _ in }
    sut.load() { _ in }

    #expect(client.requestedURLs == [url, url])
  }

  @Test func testLoadDeliversErrorOnClientError() async throws {
    let (sut, client) = makeSUT()

    expect(sut, toCompleteWithResult: .failure(.connectivity)) {
      let clientError = NSError(domain: "Test", code: 0)
      client.complete(with: clientError)
    }
  }

  @Test func testLoadDeliversErrorOnHTTPErrorStatusCode() async throws {
    let (sut, client) = makeSUT()

    let samples = [199, 201, 300, 400, 500].enumerated()

    samples.forEach { (index, code) in
      expect(sut, toCompleteWithResult: .failure(.invalidData)) {
        client.complete(withStatusCode: code, at: index)
      }
    }
  }

  @Test func testLoadDeliversErrorOnSuccessHTTPResponseWithInvalidJSON() async throws {
    let (sut, client) = makeSUT()

    expect(sut, toCompleteWithResult: .failure(.invalidData)) {
      let invalidJSON = Data("invalid json".utf8)
      client.complete(withStatusCode: 200, data: invalidJSON)
    }
  }

  @Test func testLoadDeliversNoItemsOnSuccessHTTPResponseWithEmptyJSONList() async throws {
    let (sut, client) = makeSUT()

    expect(sut, toCompleteWithResult: .success([])) {
      let emptyListJSON = Data("{\"items\": []}".utf8)
      client.complete(withStatusCode: 200, data: emptyListJSON)
    }
  }

  @Test func testLoadDeliversItemsOnSuccessHTTPResponseWithValidJSONItems() async throws {
    let (sut, client) = makeSUT()

    let itemOne = FeedItem(
        id: UUID(),
        description: nil,
        location: nil,
        imageURL: URL(string: "http://a-url.com")!
    )

    let itemOneJson = [
      "id": itemOne.id.uuidString,
      "image": itemOne.imageURL.absoluteString
    ]

    let itemTwo = FeedItem(
      id: UUID(),
      description: "a description",
      location: "a location",
      imageURL: URL(string: "http://another-url.com")!
    )

    let itemTwoJson = [
      "id": itemTwo.id.uuidString,
      "description": itemTwo.description,
      "location": itemTwo.location,
      "image": itemTwo.imageURL.absoluteString
    ]

    expect(sut, toCompleteWithResult: .success([itemOne, itemTwo])) {
      let listJSON = ["items": [itemOneJson, itemTwoJson]]
      let listData = try! JSONSerialization.data(withJSONObject: listJSON)
      client.complete(withStatusCode: 200, data: listData)
    }
  }

  // MARK: - Helpers
  private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
    let client = HTTPClientSpy()
    return (RemoteFeedLoader(url: url, client: client), client)
  }

  private func expect(
    _ sut: RemoteFeedLoader,
    toCompleteWithResult result: RemoteFeedLoader.Result,
    when action: () -> Void
  ) {
    var capturedResults: [RemoteFeedLoader.Result] = []
    sut.load() { capturedResults.append($0) }

    action()

    // cannot add file and line params with Swift Testing framework yet
    #expect(capturedResults == [result])
  }

  private class HTTPClientSpy: HTTPClient {
    private var messages: [(url: URL, completion: (HTTPClientResult) -> Void)] = []

    var requestedURLs: [URL] {
      return messages.map { $0.url }
    }

    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
      messages.append((url, completion))
    }

    func complete(with error: Error, at index: Int = 0) {
      messages[index].completion(.failure(error))
    }

    func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
      let response = HTTPURLResponse(
        url: requestedURLs[index],
        statusCode: code,
        httpVersion: nil,
        headerFields: nil
      )!
      messages[index].completion(.success(data, response))
    }
  }
}
