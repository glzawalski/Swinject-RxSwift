import Swinject

enum DI {
    static let container: Container = {
        let container = Container()

        container.register(GitHubAPI.self) { _ in
            GitHubAPIClient()
        }

        container.register(RepoRepository.self) { resolver in
            RepoRepositoryImpl(api: resolver.resolve(GitHubAPI.self)!)
        }

        container.register(SearchSwiftReposUseCase.self) { resolver in
            SearchSwiftReposUseCaseImpl(
                repo: resolver.resolve(RepoRepository.self)!
            )
        }

        container.register(RepoListViewModel.self) { resolver in
            RepoListViewModel(
                useCase: resolver.resolve(SearchSwiftReposUseCase.self)!
            )
        }

        return container
    }()
}
