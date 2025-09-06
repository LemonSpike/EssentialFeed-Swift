import Foundation

public struct URLSessionHTTPClient {
  private let session: URLSession
  
  public init(session: URLSession) {
    self.session = session
  }
  
  public func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
    session.dataTask(with: url) { _, _, error in
      if let error {
        completion(.failure(error))
      }
    }.resume()
  }
}
