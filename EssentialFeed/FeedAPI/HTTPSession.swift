import Foundation

public protocol HTTPSession {
  func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask
}

public protocol HTTPSessionTask {
  func resume()
}
