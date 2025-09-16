import EssentialFeed
import Foundation
import Testing

struct EssentialFeedAPIEndToEndTests {
  
  @Test func testEndToEndTestServerGETFeedResultMatchesFixedTestAccountData() async throws {
    switch await getFeedResult() {
    case let .success(feed):
      #expect(feed.count == 8)
      
      #expect(feed[0] == expectedItem(at: 0))
      #expect(feed[1] == expectedItem(at: 1))
      #expect(feed[2] == expectedItem(at: 2))
      #expect(feed[3] == expectedItem(at: 3))
      #expect(feed[4] == expectedItem(at: 4))
      #expect(feed[5] == expectedItem(at: 5))
      #expect(feed[6] == expectedItem(at: 6))
      #expect(feed[7] == expectedItem(at: 7))
    case let .failure(error):
      #expect(Bool(false), "Expected successful feed result, got \(error) instead")
    default:
      #expect(Bool(false), "Expected successful feed result, got no result instead")
    }
  }
  
  // MARK: - Helpers
  private func getFeedResult() async -> LoadFeedResult {
    let testServerURL = URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
    let client = URLSessionHTTPClient()
    let loader = RemoteFeedLoader(url: testServerURL, client: client)
    
    return await loader.load()
  }
  
  private func expectedItem(at index: Int) -> FeedItem {
    return FeedItem(
      id: UUID(uuidString: [
        "73A7F70C-75DA-4C2E-B5A3-EED40DC53AA6",
        "BA298A85-6275-48D3-8315-9C8F7C1CD109",
        "5A0D45B3-8E26-4385-8C5D-213E160A5E3C",
        "FF0ECFE2-2879-403F-8DBE-A83B4010B340",
        "DC97EF5E-2CC9-4905-A8AD-3C351C311001",
        "557D87F1-25D3-4D77-82E9-364B2ED9CB30",
        "A83284EF-C2DF-415D-AB73-2A9B8B04950B",
        "F79BD7F8-063F-46E2-8147-A67635C3BB01"
      ][index])!,
      description: [
        "Description 1",
        nil,
        "Description 3",
        nil,
        "Description 5",
        "Description 6",
        "Description 7",
        "Description 8"
      ][index],
      location: [
        "Location 1",
        "Location 2",
        nil,
        nil,
        "Location 5",
        "Location 6",
        "Location 7",
        "Location 8"
      ][index],
      imageURL: URL(string: "https://url-\(index+1).com")!
    )
  }
}
