import RxSwift
import RxCocoa
import Foundation

final class RepoListViewModel {

    struct Input {
        let searchTap: Signal<Void>
        let loadNextPage: Signal<Void>
    }

    struct Output {
        let repos: Driver<[Repo]>
        let loading: Driver<Bool>
        let error: Signal<String>
    }

    private let useCase: SearchSwiftReposUseCase

    init(useCase: SearchSwiftReposUseCase) {
        self.useCase = useCase
    }

    func transform(input: Input) -> Output {
        let loading = ActivityIndicator()
        let errorTracker = PublishRelay<String>()

        let page = BehaviorRelay<Int>(value: 1)

        input.searchTap
            .emit(onNext: { page.accept(1) })
            .disposed(by: disposeBag)

        input.loadNextPage
            .withLatestFrom(page.asSignal(onErrorJustReturn: 1))
            .map { $0 + 1 }
            .emit(onNext: page.accept)
            .disposed(by: disposeBag)

        let repos = page
            .flatMapLatest { [useCase] page in
                useCase.execute(page: page)
                    .trackActivity(loading)
                    .catch { error in
                        errorTracker.accept(error.localizedDescription)
                        return .empty()
                    }
            }
            .scan([]) { current, new in
                current + new
            }

        return Output(
            repos: repos.asDriver(onErrorJustReturn: []),
            loading: loading.asDriver(),
            error: errorTracker.asSignal()
        )
    }

    private let disposeBag = DisposeBag()
}
