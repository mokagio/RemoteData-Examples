enum RepoError: Error {
  case boxed(Error)
  case urlFail
  case noData
}
