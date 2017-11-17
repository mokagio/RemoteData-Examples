import Foundation

struct Repo: Decodable {
  let id: Int
  let url: URL
  let name: String
  let description: String
}
