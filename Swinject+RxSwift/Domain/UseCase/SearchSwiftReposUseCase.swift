import RxSwift

protocol SearchSwiftReposUseCase {
    func execute(page: Int) -> Observable<[Repo]>
}

final class SearchSwiftReposUseCaseImpl: SearchSwiftReposUseCase {
    private let repo: RepoRepository

    init(repo: RepoRepository) {
        self.repo = repo
    }

    func execute(page: Int) -> Observable<[Repo]> {
        repo.fetchSwiftRepos(page: page)
    }
}
