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
  func testGetFromURLFailsOnAllInvalidRepresentationCases(stub: Stub) async throws {
    _ = try await resultErrorFor(stub: stub)
  }
  
  @Test("Successful HTTPURLResponse with Data")
  func testGetFromURLSucceedsOnHTTPURLResponseWithData() async throws {
    let data = Self.anyData()
    let response = Self.anyHTTPURLResponse()
    let stub = Stub(
      data: data,
      response: response,
      error: nil
    )
    
    let receivedValues = try await resultValuesFor(stub: stub)
    
    #expect(receivedValues?.data == data)
    #expect(receivedValues?.response.url == response.url)
    #expect(receivedValues?.response.statusCode == response.statusCode)
  }
  
  @Test("Successful HTTPURLResponse with Empty Data")
  func testGetFromURLSucceedsWithEmptyDataOnHTTPURLResponseWithNilData() async throws {
    let response = Self.anyHTTPURLResponse()
    let stub = Stub(
      data: nil,
      response: response,
      error: nil
    )
    
    let receivedValues = try await resultValuesFor(stub: stub)

    let emptyData = Data()
    #expect(receivedValues?.data == emptyData)
    #expect(receivedValues?.response.url == response.url)
    #expect(receivedValues?.response.statusCode == response.statusCode)
  }
  
  // MARK: Helpers
  
  private func makeSUT() -> HTTPClient {
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
    let result = try await resultFor(stub: stub)
    switch result {
    case let .failure(error as NSError):
      return error
    default:
      let location = SourceLocation(
        fileID: fileID,
        filePath: filePath,
        line: line,
        column: column
      )
      #expect(Bool(false), "Expected failure with NSError, got \(result) instead.", sourceLocation: location)
    }
    return nil
  }
  
  private func resultValuesFor(
    stub: Stub,
    fileID: String = #fileID,
    filePath: String = #filePath,
    line: Int = #line,
    column: Int = #column
  ) async throws -> (data: Data, response: HTTPURLResponse)? {
    let result = try await resultFor(stub: stub)
    switch result {
    case let .success(data, response):
      return (data, response)
    default:
      let location = SourceLocation(
        fileID: fileID,
        filePath: filePath,
        line: line,
        column: column
      )
      #expect(Bool(false), "Expected success with data and response, got result \(result) instead.", sourceLocation: location)
    }
    return nil
  }
  
  private func resultFor(stub: Stub) async throws -> HTTPClientResult {
    URLProtocolStub.stub(with: stub)
    let sut = self.makeSUT()
    return try await sut.get(from: Self.anyURL())
  }
  
  struct Stub {
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
