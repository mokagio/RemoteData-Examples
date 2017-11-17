import ReSwift

class ReposService {

  let store: Store<AppState>

  init(store: Store<AppState>) {
    self.store = store
  }

  func getRepos() {

    store.dispatch(ReposAction.loading)

    guard let url = URL(string: "https://api.github.com/search/repositories?q=language:swift&sort:start") else {
      store.dispatch(ReposAction.failed(.urlFail))
      return
    }

    URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
      guard let store = self?.store else { return }

      if let error = error {
        store.dispatch(ReposAction.failed(RepoError.boxed(error)))
        return
      }

      guard let data = data else {
        store.dispatch(ReposAction.failed(RepoError.noData))
        return
      }

      do {
        let reposResponse = try JSONDecoder().decode(ReposResponse.self, from: data)
        store.dispatch(ReposAction.succeeded(reposResponse))
      } catch let decodeError {
        store.dispatch(ReposAction.failed(RepoError.boxed(decodeError)))
        return
      }
    }
    .resume()
  }
}
