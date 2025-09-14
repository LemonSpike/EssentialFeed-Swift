import EssentialFeed
import Foundation

extension RemoteFeedLoader {
  public func load() async throws -> Result {
    try await withCheckedThrowingContinuation { continuation in
      load { result in
        continuation.resume(returning: result)
      }
    }
  }
}
