import ReSwift

enum ReposAction: Action {
  case loading
  case succeeded(ReposResponse)
  case failed(RepoError)
}
