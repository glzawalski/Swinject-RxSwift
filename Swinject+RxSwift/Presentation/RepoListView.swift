import SwiftUI
import RxSwift
import RxCocoa
import Swinject

struct RepoListView: View {
    @StateObject private var state = RepoListState()

    private let disposeBag = DisposeBag()

    private let searchTap = PublishRelay<Void>()
    private let loadNext = PublishRelay<Void>()

    private let viewModel: RepoListViewModel

    init() {
        viewModel = DI.container.resolve(RepoListViewModel.self)!
    }

    var body: some View {
        VStack {
            Button("Search Swift Repos") {
                searchTap.accept(())
            }

            if state.isLoading {
                ProgressView()
            }

            List(state.repos) { repo in
                VStack(alignment: .leading) {
                    Text(repo.name).bold()
                    Text(repo.description ?? "")
                        .font(.caption)
                    Text("⭐️ \(repo.stargazersCount)")
                        .font(.caption2)
                }
                .onAppear {
                    if repo.id == state.repos.last?.id {
                        loadNext.accept(())
                    }
                }
            }
        }
        .onAppear {
            bindViewModel()
        }
        .alert(item: Binding(
            get: { state.error.map { ErrorWrapper(message: $0) } },
            set: { _ in state.error = nil })
        ) {
            Alert(title: Text($0.message))
        }
    }

    private func bindViewModel() {
        let input = RepoListViewModel.Input(
            searchTap: searchTap.asSignal(),
            loadNextPage: loadNext.asSignal()
        )

        let output = viewModel.transform(input: input)

        state.bind(output: output)
    }
}

struct ErrorWrapper: Identifiable {
    let id = UUID()
    let message: String
}
