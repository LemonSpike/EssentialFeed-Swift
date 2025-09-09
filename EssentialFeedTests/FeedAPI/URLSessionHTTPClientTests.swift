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
    let url = URL(string: "https://any-url.com")!
    await confirmation("Wait for request") { fulfill in
      URLProtocolStub.observeRequests { request in
        #expect(request.url == url)
        #expect(request.httpMethod == "GET")
        fulfill()
      }
      
      _ = try? await makeSUT().get(from: url)
    }
  }
  
  @Test func testGetFromURLFailsOnRequestError() async throws {
    let url = URL(string: "https://any-url.com")!
    let error = NSError(domain: "Any Error", code: 1)
    URLProtocolStub.stub(
      data: nil,
      response: nil,
      error: error
    )
    
    let result = try await makeSUT().get(from: url)
    switch result {
    case let .failure(receivedError as NSError):
      #expect(receivedError.domain == error.domain)
      #expect(receivedError.code == error.code)
    default:
      #expect(Bool(false), "Expected failure with error \(error), got \(result) instead.")
    }
  }
  
  // MARK: Helpers
  
  private func makeSUT() -> URLSessionHTTPClient {
    URLSessionHTTPClient()
  }
  
  private class URLProtocolStub: URLProtocol {
    private static var stub: Stub?
    private static var requestObserver: ((URLRequest) -> Void)?
    
    private struct Stub {
      let data: Data?
      let response: URLResponse?
      let error: Error?
    }
    
    static func stub(
      data: Data?,
      response: URLResponse?,
      error: Error? = nil
    ) {
      stub = Stub(
        data: data,
        response: response,
        error: error
      )
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
