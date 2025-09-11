import Foundation
import Testing
import EssentialFeed

@Suite
class URLSessionHTTPClientTests {
  
  init() {
    URLProtocolStub.startInterceptingRequests()
  }
  
  deinit {
    URLProtocolStub.stopInterceptingRequests()
  }
  
  @Test func testGetFromURLPerformsGETRequestWithURL() async throws {
    try await LeakChecker { [weak self] checker in
      guard let self else { return }
      let url = self.anyURL()
      try await confirmation("Wait for request") { fulfill in
        URLProtocolStub.observeRequests { request in
          #expect(request.url == url)
          #expect(request.httpMethod == "GET")
          fulfill()
        }
        
        _ = try await self.makeSUT().get(from: url)
      }
    }
  }
  
  @Test func testGetFromURLFailsOnRequestError() async throws {
    try await LeakChecker { [weak self] checker in
      guard let self else { return }
      let requestError = NSError(domain: "Any Error", code: 1)
      let stub = Stub(data: nil, response: nil, error: requestError)
      let receivedError = try await resultErrorFor(stub: stub) as? NSError
      
      #expect(receivedError?.domain == requestError.domain)
      #expect(receivedError?.code == requestError.code)
    }
  }
  
  @Test(
    "Invalid representation yields error",
    arguments: [
      // (data, response, error)
      Stub(data: nil,
       response: URLResponse(url: URL(string: "https://any-url.com")!, mimeType: nil, expectedContentLength: 0, textEncodingName: nil),
       error: nil),
      Stub(data: "any data".data(using: .utf8),
       response: nil,
       error: NSError(domain: "Any Error", code: 1)),
      Stub(data: nil,
       response: URLResponse(url: URL(string: "https://any-url.com")!, mimeType: nil, expectedContentLength: 0, textEncodingName: nil),
       error: NSError(domain: "Any Error", code: 1)),
      Stub(data: nil,
       response: HTTPURLResponse(url: URL(string: "https://any-url.com")!, statusCode: 200, httpVersion: nil, headerFields: nil),
       error: NSError(domain: "Any Error", code: 1))
    ])
  private func testGetFromURLFailsOnAllInvalidRepresentationCases(stub: Stub) async throws {
    try await LeakChecker { [weak self] checker in
      guard let self else { return }
      let receivedError = try await resultErrorFor(stub: stub)
      #expect(receivedError != nil, sourceLocation: SourceLocation(fileID: #fileID, filePath: #filePath, line: #line, column: #column))
    }
  }
    
  // MARK: Helpers
  
  private func makeSUT(
    fileID: String = #fileID,
    filePath: String = #filePath,
    line: Int = #line,
    column: Int = #column
  ) -> URLSessionHTTPClient {
    URLSessionHTTPClient()
  }
  
  private func anyURL() -> URL {
    URL(string: "https://any-url.com")!
  }
  
  private func resultErrorFor(
    stub: Stub,
    fileID: String = #fileID,
    filePath: String = #filePath,
    line: Int = #line,
    column: Int = #column
  ) async throws -> Error? {
    URLProtocolStub.stub(with: stub)
    
    let sut = self.makeSUT(
      fileID: fileID,
      filePath: filePath,
      line: line,
      column: column
    )
    
    var receivedError: Error?
    let result = try await sut.get(from: self.anyURL())
    switch result {
    case let .failure(error as NSError):
      receivedError = error
    default:
      break
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
    
    static func stub(
      with stub: Stub
    ) {
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
