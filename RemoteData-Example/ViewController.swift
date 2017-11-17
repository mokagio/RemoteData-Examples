import UIKit

class ViewController: UIViewController {

  @IBOutlet var loadingSpinner: UIActivityIndicatorView!
  @IBOutlet var tableView: UITableView!

  var repos: RemoteData<[Repo], RepoError> = .notAsked

  let cellIdentifier = "cell"

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "RemoteData Example"

    tableView.dataSource = self
    
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    update(with: .loading)

    getRepos { [weak self] remoteData in
      self?.update(with: remoteData.map { $0.repos })
    }
  }

  private func getRepos(completion: @escaping (RemoteData<ReposResponse, RepoError>) -> ()) {
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

  private func update(with data: RemoteData<[Repo], RepoError>) {
    repos = data

    DispatchQueue.main.async { [unowned self] in
      switch self.repos {
      case .notAsked:
        // We could have a button to trigger the load here. Although in the case of an app showing
        // a list of repos it's better to start loading automatically.
        self.tableView.isHidden = true
        self.loadingSpinner.isHidden = true
        break
      case .loading:
        self.tableView.isHidden = true
        self.loadingSpinner.isHidden = false
        self.loadingSpinner.startAnimating()
      case .success(let repos):
        self.tableView.isHidden = false
        self.tableView.reloadData()
        self.loadingSpinner.isHidden = true
        self.loadingSpinner.stopAnimating()
        break
      case .failure(_):
        break
      }
    }
  }
}

extension ViewController: UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch repos {
    case .success(let repos):
      return repos.count
    case _:
      return 0
    }
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch repos {
    case .success(let repos):
      let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
      let repo = repos[indexPath.row]

      cell.textLabel?.text = repo.name
      cell.detailTextLabel?.text = repo.name

      return cell
    case _:
      return UITableViewCell()
    }
  }
}

enum RepoError: Error {
  case boxed(Error)
  case urlFail
  case noData
}

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

struct Repo: Decodable {
  let id: Int
  let url: URL
  let name: String
  let description: String
}


//
//
//

public enum RemoteData<T, E: Error> {
  case notAsked
  case loading
  case failure(E)
  case success(T)
}

extension RemoteData {

  public init(value: T) {
    self = .success(value)
  }

  public func map<U>(_ transform: (T) -> U) -> RemoteData<U, E> {
    switch self {
    case .success(let value): return .success(transform(value))
    case .failure(let error): return .failure(error)
    case .loading: return .loading
    case .notAsked: return .notAsked
    }
  }

  public func mapError<F: Error>(_ transform: (E) -> F) -> RemoteData<T, F> {
    switch self {
    case .success(let value): return .success(value)
    case .failure(let error): return .failure(transform(error))
    case .loading: return .loading
    case .notAsked: return .notAsked
    }
  }
}
