import Foundation
import Testing
import EssentialFeed

struct RemoteFeedLoaderTests {
  @Test func testInitDoesNotRequestDataFromURL() async throws {
    LeakChecker { checker in
      let (sut, client) = makeSUT()
      checker.checkForMemoryLeak(client)
      checker.checkForMemoryLeak(sut)

      #expect(client.requestedURLs.isEmpty)
    }
  }

  @Test func testLoadRequestsDataFromURL() async throws {
    LeakChecker { checker in
      let url = URL(string: "https://a-given-url.com")!
      let (sut, client) = makeSUT(url: url)
      checker.checkForMemoryLeak(client)
      checker.checkForMemoryLeak(sut)

      sut.load() { _ in }

      #expect(client.requestedURLs == [url])
    }
  }

  @Test func testLoadTwiceRequestsDataFromURLTwice() async throws {
    LeakChecker { checker in
      let url = URL(string: "https://a-given-url.com")!
      let (sut, client) = makeSUT(url: url)
      checker.checkForMemoryLeak(client)
      checker.checkForMemoryLeak(sut)

      sut.load() { _ in }
      sut.load() { _ in }

      #expect(client.requestedURLs == [url, url])
    }
  }

  @Test func testLoadDeliversErrorOnClientError() async throws {
    LeakChecker { checker in
      let (sut, client) = makeSUT()
      checker.checkForMemoryLeak(client)
      checker.checkForMemoryLeak(sut)

      expect(sut, toCompleteWithResult: .failure(.connectivity)) {
        let clientError = NSError(domain: "Test", code: 0)
        client.complete(with: clientError)
      }
    }
  }

  @Test func testLoadDeliversErrorOnHTTPErrorStatusCode() async throws {
    LeakChecker { checker in
      let (sut, client) = makeSUT()
      checker.checkForMemoryLeak(client)
      checker.checkForMemoryLeak(sut)

      let samples = [199, 201, 300, 400, 500].enumerated()

      samples.forEach { (index, code) in
        expect(sut, toCompleteWithResult: .failure(.invalidData)) {
          let json = makeItemsJson([])
          client.complete(withStatusCode: code, data: json, at: index)
        }
      }
    }
  }

  @Test func testLoadDeliversErrorOnSuccessHTTPResponseWithInvalidJSON() async throws {
    LeakChecker { checker in
      let (sut, client) = makeSUT()
      checker.checkForMemoryLeak(client)
      checker.checkForMemoryLeak(sut)

      expect(sut, toCompleteWithResult: .failure(.invalidData)) {
        let invalidJSON = Data("invalid json".utf8)
        client.complete(withStatusCode: 200, data: invalidJSON)
      }
    }
  }

  @Test func testLoadDeliversNoItemsOnSuccessHTTPResponseWithEmptyJSONList() async throws {
    LeakChecker { checker in
      let (sut, client) = makeSUT()
      checker.checkForMemoryLeak(client)
      checker.checkForMemoryLeak(sut)

      expect(sut, toCompleteWithResult: .success([])) {
        let emptyListJSON = makeItemsJson([])
        client.complete(withStatusCode: 200, data: emptyListJSON)
      }
    }
  }

  @Test func testLoadDeliversItemsOnSuccessHTTPResponseWithValidJSONItems() async throws {
    LeakChecker { checker in
      let (sut, client) = makeSUT()
      checker.checkForMemoryLeak(client)
      checker.checkForMemoryLeak(sut)

      let itemOne = makeItem(
        id: UUID(),
        imageUrl: URL(string: "http://a-url.com")!
      )

      let itemTwo = makeItem(
        id: UUID(),
        description: "a description",
        location: "a location",
        imageUrl: URL(string: "http://another-url.com")!
      )

      let itemsJSON = [itemOne.json, itemTwo.json]
      let items = [itemOne.model, itemTwo.model]

      expect(sut, toCompleteWithResult: .success(items)) {
        let listData = makeItemsJson(itemsJSON)
        client.complete(withStatusCode: 200, data: listData)
      }
    }
  }

  @Test func testLoadDoesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() async throws {
    LeakChecker { checker in
      let url = URL(string: "https://a-url.com")!
      let client = HTTPClientSpy()
      var sut: RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)
      checker.checkForMemoryLeak(client)

      var capturedResults: [RemoteFeedLoader.Result] = []
      sut?.load() { capturedResults.append($0) }

      sut = nil
      client.complete(withStatusCode: 200, data: makeItemsJson([]))

      #expect(capturedResults.isEmpty)
    }
  }

  // MARK: - Helpers
  private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
    let client = HTTPClientSpy()
    return (RemoteFeedLoader(url: url, client: client), client)
  }

  private func makeItem(
    id: UUID,
    description: String? = nil,
    location: String? = nil,
    imageUrl: URL
  ) -> (model: FeedItem, json:[String: Any]) {
    let item = FeedItem(
      id: id,
      description: description,
      location: location,
      imageURL: imageUrl
    )
    let json = [
      "id": id.uuidString,
      "description": description,
      "location": location,
      "image": imageUrl.absoluteString
    ].compactMapValues { $0 }
    return (item, json)
  }

  private func makeItemsJson(_ items: [[String: Any]]) -> Data {
    let json = ["items": items]
    return try! JSONSerialization.data(withJSONObject: json)
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

    func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
      guard (0..<messages.count).contains(index) else {
        fatalError("Invalid message index, call the load method before completing a request")
      }
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
