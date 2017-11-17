import UIKit
import ReSwift
import RemoteData

class ViewController: UIViewController {

  @IBOutlet var loadingSpinner: UIActivityIndicatorView!
  @IBOutlet var tableView: UITableView!

  let reposService = ReposService(store: mainStore)

  var repos: RemoteData<[Repo], RepoError> = .notAsked

  let cellIdentifier = "cell"

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "RemoteData + ReSwift Example"

    tableView.dataSource = self

    tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    mainStore.subscribe(self)
    reposService.getRepos()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    mainStore.unsubscribe(self)
  }
}

extension ViewController: StoreSubscriber {

  func newState(state: AppState) {
    repos = state.repos

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
      case .success:
        self.tableView.isHidden = false
        self.tableView.reloadData()
        self.loadingSpinner.isHidden = true
        self.loadingSpinner.stopAnimating()
        break
      case .failure:
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
