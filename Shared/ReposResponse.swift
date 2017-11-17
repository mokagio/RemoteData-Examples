struct ReposResponse {
  let repos: [Repo]
}
extension ReposResponse: Decodable {
  enum CodingKeys: String, CodingKey {
    case repos = "items"
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let repos: [Repo] = try container.decode([Repo].self, forKey: .repos)
    self.init(repos: repos)
  }
}
