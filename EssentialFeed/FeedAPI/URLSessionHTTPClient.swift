import Foundation

public struct URLSessionHTTPClient {
  private let session: URLSession
  
  public init(session: URLSession) {
    self.session = session
  }
  
  public func get(from url: URL) {
    session.dataTask(with: url) { _, _, _ in
      
    }.resume()
  }
}
