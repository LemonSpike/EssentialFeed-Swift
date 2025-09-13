import Foundation
import Testing
import EssentialFeed

@Suite
class URLSessionHTTPClientTests {
  
  private static let stubs = [
    Stub(
      data: nil,
      response: nonHTTPURLResponse(),
      error: nil
    ),
    Stub(
      data: nil,
      response: anyHTTPURLResponse(),
      error: nil
    ),
    Stub(
      data: anyData(),
      response: nil,
      error: anyNSError()
    ),
    Stub(
      data: nil,
      response: nonHTTPURLResponse(),
      error: anyNSError()
    ),
    Stub(
      data: nil,
      response: anyHTTPURLResponse(),
      error: anyNSError()
    ),
    Stub(
      data: anyData(),
      response: nonHTTPURLResponse(),
      error: anyNSError()
    ),
    Stub(
      data: anyData(),
      response: nonHTTPURLResponse(),
      error: nil
    )
  ]
  
  init() {
    URLProtocolStub.startInterceptingRequests()
  }
  
  deinit {
    URLProtocolStub.stopInterceptingRequests()
  }
  
  @Test func testGetFromURLPerformsGETRequestWithURL() async throws {
    let url = Self.anyURL()
    try await confirmation("Wait for request") { fulfill in
      URLProtocolStub.observeRequests { request in
        #expect(request.url == url)
        #expect(request.httpMethod == "GET")
        fulfill()
      }
      
      _ = try await self.makeSUT().get(from: url)
    }
  }
  
  @Test func testGetFromURLFailsOnRequestError() async throws {
    let requestError = Self.anyNSError()
    let stub = Stub(data: nil, response: nil, error: requestError)
    let receivedError = try await resultErrorFor(stub: stub) as? NSError
    
    #expect(receivedError?.domain == requestError.domain)
    #expect(receivedError?.code == requestError.code)
  }
  
  @Test(
    "Invalid representation yields error",
    arguments: stubs
  )
  private func testGetFromURLFailsOnAllInvalidRepresentationCases(stub: Stub) async throws {
    _ = try await resultErrorFor(stub: stub)
  }
  
  @Test("Successful HTTPURLResponse with Data")
  func testGetFromURLSucceedsOnHTTPURLResponseWithData() async throws {
    URLProtocolStub.stub(
      with: Stub(
        data: Self.anyData(),
        response: Self.anyHTTPURLResponse(),
        error: nil
      )
    )
    
    let result = try await makeSUT().get(from: Self.anyURL())
    switch result {
    case let .success(data, response):
      #expect(data == Self.anyData())
      #expect(response.url == Self.anyURL())
      #expect(response.statusCode == 200)
    case .failure(let error):
      #expect(Bool(false), "Expected success, got an error \(error.localizedDescription) instead.")
    @unknown default:
      #expect(Bool(false), "Expected success, got a different result \(result) instead.")
    }
  }
  
  // MARK: Helpers
  
  private func makeSUT() -> URLSessionHTTPClient {
    URLSessionHTTPClient()
  }
  
  private static func anyURL() -> URL {
    URL(string: "https://any-url.com")!
  }
  
  private static func anyData() -> Data {
    "any data".data(using: .utf8)!
  }
  
  private static func anyNSError() -> NSError {
    NSError(domain: "Any Error", code: 1)
  }
  
  private static func nonHTTPURLResponse() -> URLResponse {
    URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
  }
  
  private static func anyHTTPURLResponse() -> HTTPURLResponse {
    HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
  }
  
  private func resultErrorFor(
    stub: Stub,
    fileID: String = #fileID,
    filePath: String = #filePath,
    line: Int = #line,
    column: Int = #column
  ) async throws -> Error? {
    URLProtocolStub.stub(with: stub)
    
    let sut = self.makeSUT()
    
    var receivedError: Error?
    let result = try await sut.get(from: Self.anyURL())
    switch result {
    case let .failure(error as NSError):
      receivedError = error
    default:
      let location = SourceLocation(
        fileID: fileID,
        filePath: filePath,
        line: line,
        column: column
      )
      #expect(Bool(false), "Expected failure with error, got \(result) instead.", sourceLocation: location)
    }
    return receivedError
  }
  
  private struct Stub {
    let data: Data?
    let response: URLResponse?
    let error: Error?
  }
  
  private class URLProtocolStub: URLProtocol {
    private static var stub: Stub?
    private static var requestObserver: ((URLRequest) -> Void)?
    
    static func stub(with stub: Stub) {
      self.stub = stub
    }
    
    static func observeRequests(observer: @escaping (URLRequest) -> Void) {
      requestObserver = observer
    }
    
    static func startInterceptingRequests() {
      URLProtocol.registerClass(URLProtocolStub.self)
    }
    
    static func stopInterceptingRequests() {
      URLProtocol.unregisterClass(URLProtocolStub.self)
      stub = nil
      requestObserver = nil
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
      requestObserver?(request)
      return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
      request
    }
    
    override func startLoading() {
      guard let stub = URLProtocolStub.stub else {
        client?.urlProtocol(self, didFailWithError: NSError(domain: "URLProtocolStub", code: 1, userInfo: [NSLocalizedDescriptionKey: "No stub available"]))
        client?.urlProtocolDidFinishLoading(self)
        return
      }
      
      if let data = stub.data {
        client?.urlProtocol(self, didLoad: data)
      }
      
      if let response = stub.response {
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
      }
      
      if let error = stub.error {
        client?.urlProtocol(self, didFailWithError: error)
      }
      
      client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
  }
}
