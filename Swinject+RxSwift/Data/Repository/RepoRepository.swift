import RxSwift

protocol RepoRepository {
    func fetchSwiftRepos(page: Int) -> Observable<[Repo]>
}

final class RepoRepositoryImpl: RepoRepository {
    private let api: GitHubAPI

    init(api: GitHubAPI) {
        self.api = api
    }

    func fetchSwiftRepos(page: Int) -> Observable<[Repo]> {
        api.searchSwiftRepos(page: page)
    }
}
