import Combine
import Foundation

final class GameManager: ObservableObject {
    @Published private(set) var completedLevels: Set<Int>
    @Published var isHubUnlocked: Bool

    private var store: ProgressStoreProtocol    // <-- var вместо let
    private let lockService = DateLockService()
    private var cancellables = Set<AnyCancellable>()

    init(store: ProgressStoreProtocol = UserDefaultsProgressStore()) {
        self.store = store
        self.completedLevels = store.completedLevels
        self.isHubUnlocked = lockService.isUnlocked()

        // Сохраняем прогресс
        $completedLevels
            .sink { [weak self] newLevels in
                self?.store.completedLevels = newLevels
                self?.store.synchronize()
            }
            .store(in: &cancellables)
    }

    /// Отметить уровень как пройденный
    func complete(level: Int) {
        completedLevels.insert(level)
    }
}
