import ReSwift
import RemoteData

struct AppState: StateType {
  var repos: RemoteData<[Repo], RepoError> = .notAsked
}
