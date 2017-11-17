import Foundation

class ReposService {

  func getRepos(completion: @escaping (RemoteData<ReposResponse, RepoError>) -> ()) {
    guard let url = URL(string: "https://api.github.com/search/repositories?q=language:swift&sort:start") else {
      completion(RemoteData.failure(.urlFail))
      return
    }

    URLSession.shared.dataTask(with: url) { data, response, error in
      if let error = error {
        completion(RemoteData.failure(RepoError.boxed(error)))
        return
      }

      guard let data = data else {
        completion(RemoteData.failure(RepoError.noData))
        return
      }

      do {
        let reposResponse = try JSONDecoder().decode(ReposResponse.self, from: data)
        completion(RemoteData.success(reposResponse))
      } catch let decodeError {
        completion(RemoteData.failure(RepoError.boxed(decodeError)))
        return
      }
    }
    .resume()
  }
}
