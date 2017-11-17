import ReSwift
import RemoteData

func appReducer(action: Action, state: AppState?) -> AppState {
  let inputState = state ?? AppState()

  switch action {
  case let action as ReposAction:
    return reposReducer(action: action, state: inputState)
  case _:
    break
  }

  return inputState
}

func reposReducer(action: ReposAction, state: AppState) -> AppState {
  var outputState = state

  switch action {
  case .failed(let error):
    outputState.repos = .failure(error)
  case .loading:
    outputState.repos = .loading
  case .succeeded(let response):
    outputState.repos = RemoteData<ReposResponse, RepoError>.success(response)
      .map { (response: ReposResponse) -> [Repo] in
        response.repos
    }
  }

  return outputState
}
