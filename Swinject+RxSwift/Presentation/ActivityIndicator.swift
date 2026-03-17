import Foundation
import RxSwift
import RxCocoa

public final class ActivityIndicator: SharedSequenceConvertibleType {
    public typealias Element = Bool
    public typealias SharingStrategy = DriverSharingStrategy

    private let lock = NSRecursiveLock()
    private let relay = BehaviorRelay(value: 0)
    private let loading: SharedSequence<DriverSharingStrategy, Bool>

    public init() {
        loading = relay
            .asDriver()
            .map { $0 > 0 }
            .distinctUntilChanged()
    }

    fileprivate func trackActivityOfObservable<O: ObservableConvertibleType>(
        _ source: O
    ) -> Observable<O.Element> {

        return Observable.using(
            { () -> ActivityToken<O.Element> in
                self.increment()
                return ActivityToken(source: source.asObservable(), disposeAction: self.decrement)
            },
            observableFactory: { token in
                token.asObservable()
            }
        )
    }

    private func increment() {
        lock.lock()
        relay.accept(relay.value + 1)
        lock.unlock()
    }

    private func decrement() {
        lock.lock()
        relay.accept(relay.value - 1)
        lock.unlock()
    }

    public func asSharedSequence() -> SharedSequence<SharingStrategy, Bool> {
        loading
    }
}

private struct ActivityToken<E>: ObservableConvertibleType, Disposable {
    private let source: Observable<E>
    private let disposeAction: () -> Void

    init(source: Observable<E>, disposeAction: @escaping () -> Void) {
        self.source = source
        self.disposeAction = disposeAction
    }

    func asObservable() -> Observable<E> {
        source
    }

    func dispose() {
        disposeAction()
    }
}

extension ObservableConvertibleType {
    func trackActivity(_ activityIndicator: ActivityIndicator)
        -> Observable<Element> {
        activityIndicator.trackActivityOfObservable(self)
    }
}
