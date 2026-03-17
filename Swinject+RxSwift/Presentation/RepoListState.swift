import Combine
import RxSwift
import RxCocoa

final class RepoListState: ObservableObject {
    @Published var repos: [Repo] = []
    @Published var isLoading = false
    @Published var error: String?

    private let disposeBag = DisposeBag()

    func bind(output: RepoListViewModel.Output) {
        output.repos
            .drive(onNext: { [weak self] in self?.repos = $0 })
            .disposed(by: disposeBag)

        output.loading
            .drive(onNext: { [weak self] in self?.isLoading = $0 })
            .disposed(by: disposeBag)

        output.error
            .emit(onNext: { [weak self] in self?.error = $0 })
            .disposed(by: disposeBag)
    }
}
